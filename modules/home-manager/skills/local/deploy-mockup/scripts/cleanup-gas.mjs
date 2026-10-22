// Archive (delete) the Apps Script deployment of a branch that is gone.
// The deployment's versions stay in project history; only its URL stops working.
//
//   node scripts/cleanup-gas.mjs <branch>   archive one branch's deployment
//   node scripts/cleanup-gas.mjs --prune     archive deployments whose branch no longer exists on origin
//   add --dry-run to only list what would be archived
//
// The production deployment is never archived.
import { PRODUCTION_BRANCH, clasp, describeBranch, fail, git, listBranchDeployments, readRegistry, scriptId, withDeploymentLock } from './gas-lib.mjs';

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const prune = args.includes('--prune');
const named = args.filter((a) => !a.startsWith('--'));
if (!prune && named.length !== 1) fail('Usage: node scripts/cleanup-gas.mjs <branch> | --prune [--dry-run]');

const pinned = new Set(Object.values(readRegistry()).map((r) => r.deploymentId));
const protectedBranch = (b) => b === PRODUCTION_BRANCH;

await withDeploymentLock(scriptId(), async () => {
  const deployments = listBranchDeployments();
  let targets;
  if (prune) {
    const remote = new Set(
      git('ls-remote', '--heads', 'origin')
        .split('\n')
        .filter(Boolean)
        .map((l) => l.split('refs/heads/')[1]),
    );
    targets = [...deployments.keys()].filter((b) => !remote.has(b));
  } else {
    targets = named;
    if (!deployments.has(named[0])) return console.log(`No deployment described "${describeBranch(named[0])}"; nothing to archive.`);
  }
  for (const b of targets) {
    const d = deployments.get(b);
    if (protectedBranch(b) || pinned.has(d.deploymentId)) {
      console.log(`Keeping ${b} (production).`);
      continue;
    }
    if (dryRun) {
      console.log(`Would archive ${b} (${d.deploymentId}, version ${d.versionNumber})`);
      continue;
    }
    clasp(['delete-deployment', d.deploymentId]);
    console.log(`Archived ${b} (${d.deploymentId}); its URL no longer serves the app.`);
  }
  if (!targets.length) console.log('Nothing to archive.');
});
