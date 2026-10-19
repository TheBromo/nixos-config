// Shared helpers for the Google Apps Script build and deployment scripts.
import { spawnSync } from 'node:child_process';
import { closeSync, existsSync, openSync, readFileSync, statSync, unlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
export const GAS_OUT = join(ROOT, 'build', 'gas');
export const CLASP_JSON = join(ROOT, '.clasp.json');
export const REGISTRY = join(ROOT, 'deployments.json');

/** The branch whose deployment is production; its URL must never change. */
export const PRODUCTION_BRANCH = process.env.GAS_PRODUCTION_BRANCH || 'main';

/** Deployment descriptions are the lookup key: recoverable from Apps Script itself. */
export const describeBranch = (branch) => `branch:${branch}`;
export const branchOf = (description) => (description?.startsWith('branch:') ? description.slice('branch:'.length) : null);
export const webAppUrl = (deploymentId) => `https://script.google.com/macros/s/${deploymentId}/exec`;

export function fail(message) {
  console.error(`\n✖ ${message}`);
  process.exit(1);
}

/** Run a command; returns stdout. Throws with its output on failure. */
export function run(cmd, args, { quiet = false, cwd = ROOT } = {}) {
  const r = spawnSync(cmd, args, { cwd, encoding: 'utf8', stdio: quiet ? ['ignore', 'pipe', 'pipe'] : ['ignore', 'pipe', 'inherit'], env: process.env });
  if (r.error) throw r.error;
  if (r.status !== 0) {
    const out = [r.stdout, r.stderr].filter(Boolean).join('\n').trim();
    throw new Error(`${cmd} ${args.join(' ')} failed (exit ${r.status})${out ? `:\n${out}` : ''}`);
  }
  return r.stdout ?? '';
}

export const git = (...args) => run('git', args, { quiet: true }).trim();

/** The branch being deployed: CI's ref name, else the checked-out branch. */
export function currentBranch() {
  const fromCi = process.env.GAS_BRANCH || process.env.GITHUB_HEAD_REF || process.env.GITHUB_REF_NAME;
  const branch = fromCi || git('rev-parse', '--abbrev-ref', 'HEAD');
  if (!branch || branch === 'HEAD') fail('Not on a branch (detached HEAD). Check out a branch, or set GAS_BRANCH.');
  return branch;
}

export function commitInfo() {
  const sha = git('rev-parse', '--short', 'HEAD');
  const dirty = git('status', '--porcelain').length > 0;
  return { sha, dirty };
}

/** clasp from this project's devDependencies, with JSON output parsed. */
export function clasp(args, { json = true } = {}) {
  const out = run('npx', ['--no-install', 'clasp', ...(json ? ['--json'] : []), ...args], { quiet: true });
  if (!json) return out;
  // Anything before the JSON (warnings, spinners) is ignored.
  const start = out.search(/^[[{]/m);
  if (start < 0) throw new Error(`clasp ${args[0]}: expected JSON output, got:\n${out}`);
  return JSON.parse(out.slice(start));
}

export function scriptId() {
  if (!existsSync(CLASP_JSON)) fail('No .clasp.json. Run `npm run setup:gas` once to create the Apps Script project (see DEPLOY.md).');
  const id = JSON.parse(readFileSync(CLASP_JSON, 'utf8')).scriptId;
  if (!id) fail('.clasp.json has no scriptId.');
  return id;
}

/** Versioned deployments, keyed by branch (from their `branch:<name>` description). The @HEAD deployment is skipped. */
export function listBranchDeployments() {
  const all = clasp(['list-deployments']);
  const byBranch = new Map();
  for (const d of all) {
    const branch = branchOf(d.description);
    if (!branch || !d.versionNumber) continue;
    if (byBranch.has(branch)) fail(`Two deployments are described "${describeBranch(branch)}": ${byBranch.get(branch).deploymentId} and ${d.deploymentId}. Delete one before deploying.`);
    byBranch.set(branch, d);
  }
  return byBranch;
}

/** The committed registry: pins the production deployment ID so its URL can never be replaced by accident. */
export function readRegistry() {
  if (!existsSync(REGISTRY)) return {};
  return JSON.parse(readFileSync(REGISTRY, 'utf8'));
}
export function writeRegistry(reg) {
  writeFileSync(REGISTRY, `${JSON.stringify(reg, null, 2)}\n`);
}

/**
 * Serialize the remote push → version → deploy sequence on this machine. A
 * second deploy waits (CI runs are serialized by the workflow's concurrency
 * group). A lock left by a dead process, or older than 20 minutes, is taken over.
 */
export async function withDeploymentLock(id, f) {
  const path = join(tmpdir(), `gas-deploy-${id}.lock`);
  const deadline = Date.now() + 10 * 60_000;
  for (;;) {
    try {
      const fd = openSync(path, 'wx');
      writeFileSync(fd, String(process.pid));
      closeSync(fd);
      break;
    } catch (e) {
      if (e.code !== 'EEXIST') throw e;
      if (lockIsStale(path)) {
        unlinkSync(path);
        continue;
      }
      if (Date.now() > deadline) fail(`Another deployment holds ${path}. Remove it if no deployment is running.`);
      console.log('Waiting for another deployment of this Apps Script project to finish…');
      await new Promise((r) => setTimeout(r, 5000));
    }
  }
  const release = () => existsSync(path) && readFileSync(path, 'utf8') === String(process.pid) && unlinkSync(path);
  process.once('SIGINT', () => {
    release();
    process.exit(130);
  });
  try {
    return await f();
  } finally {
    release();
  }
}

function lockIsStale(path) {
  try {
    if (Date.now() - statSync(path).mtimeMs > 20 * 60_000) return true;
    const pid = Number(readFileSync(path, 'utf8'));
    if (!pid) return true;
    process.kill(pid, 0);
    return false;
  } catch (e) {
    return e.code === 'ESRCH' || e.code === 'ENOENT';
  }
}
