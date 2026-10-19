// Deploy the current Git branch to its own, permanent Apps Script URL.
//
//   first deployment of a branch  → a new deployment (new URL)
//   later deployments             → the same deployment moves to a new version (same URL)
//   other branches                → untouched: each deployment points at its own immutable version
//
// The lookup key is the deployment description `branch:<name>`, so the mapping
// lives in Apps Script itself and is shared by every machine and CI run. The
// production deployment is also pinned in deployments.json (committed): if the
// pinned deployment is missing, the deploy stops instead of creating a new
// production URL.
import { buildGas } from './build-gas.mjs';
import {
  PRODUCTION_BRANCH,
  clasp,
  commitInfo,
  currentBranch,
  describeBranch,
  fail,
  listBranchDeployments,
  readRegistry,
  run,
  scriptId,
  webAppUrl,
  withDeploymentLock,
  writeRegistry,
} from './gas-lib.mjs';

/** Apps Script keeps at most 200 versions per project; old ones must be deleted in the editor. */
const VERSION_WARN = 180;

const branch = currentBranch();
const production = branch === PRODUCTION_BRANCH;
const { sha, dirty } = commitInfo();
if (production && dirty && !process.argv.includes('--allow-dirty')) {
  fail(`${PRODUCTION_BRANCH} has uncommitted changes. Commit them first (or pass --allow-dirty).`);
}
const id = scriptId();

const url = await withDeploymentLock(id, async () => {
  // 1. Build, then 2. replace the project's working source with it.
  buildGas(branch);
  console.log('Pushing to Apps Script…');
  run('npx', ['--no-install', 'clasp', 'push', '--force'], { quiet: true });

  // 3. An immutable version of exactly what was pushed.
  const label = `${branch} @${sha}${dirty ? '+dirty' : ''}`;
  const { versionNumber } = clasp(['create-version', label]);
  if (!versionNumber) fail('clasp did not return a version number.');
  console.log(`Created version ${versionNumber} (${label})`);
  if (versionNumber >= VERSION_WARN) console.warn(`⚠ Version ${versionNumber} of at most 200: delete old versions in the Apps Script editor (Project history).`);

  // 4. This branch's deployment, if it has one.
  const existing = listBranchDeployments().get(branch);
  const registry = readRegistry();
  const pinned = registry[branch]?.deploymentId;
  if (pinned && existing && existing.deploymentId !== pinned) {
    fail(`deployments.json pins ${branch} to ${pinned}, but Apps Script describes ${existing.deploymentId} as "${describeBranch(branch)}". Resolve this before deploying.`);
  }
  if (production && pinned && !existing) {
    fail(`The pinned production deployment ${pinned} was not found. Not creating a new production URL; check \`npm run deployments:gas\`.`);
  }

  let deploymentId;
  if (existing) {
    // Same deployment, new version: the URL stays.
    clasp(['update-deployment', existing.deploymentId, '--versionNumber', String(versionNumber), '--description', describeBranch(branch)]);
    deploymentId = existing.deploymentId;
    console.log(`Updated ${branch}: version ${existing.versionNumber} → ${versionNumber}`);
  } else {
    const d = clasp(['create-deployment', '--versionNumber', String(versionNumber), '--description', describeBranch(branch)]);
    deploymentId = d.deploymentId;
    if (!deploymentId) fail('clasp did not return a deployment ID.');
    console.log(`Created a deployment for ${branch}`);
  }

  // 5. Pin production (commit deployments.json once, from main). Previews are looked up by description.
  if (production && registry[branch]?.deploymentId !== deploymentId) {
    writeRegistry({ ...registry, [branch]: { deploymentId, environment: 'production' } });
    console.log('Pinned the production deployment in deployments.json: commit it.');
  }
  return webAppUrl(deploymentId);
});

console.log(`\n${production ? 'Production' : 'Preview'} · ${branch}\n${url}`);
if (process.env.GITHUB_STEP_SUMMARY) {
  const { appendFileSync } = await import('node:fs');
  appendFileSync(process.env.GITHUB_STEP_SUMMARY, `### ${production ? 'Production' : 'Preview'}: \`${branch}\`\n\n${url}\n`);
}
