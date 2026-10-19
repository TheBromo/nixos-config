// List every branch deployment with its version and URL (read from Apps Script).
import { PRODUCTION_BRANCH, listBranchDeployments, readRegistry, scriptId, webAppUrl } from './gas-lib.mjs';

scriptId();
const pinned = readRegistry();
const rows = [...listBranchDeployments().entries()].sort(([a], [b]) => (a === PRODUCTION_BRANCH ? -1 : b === PRODUCTION_BRANCH ? 1 : a.localeCompare(b)));
if (!rows.length) console.log('No branch deployments yet. Run `npm run deploy:gas` on a branch.');
for (const [branch, d] of rows) {
  const kind = branch === PRODUCTION_BRANCH ? 'production' : 'preview';
  const mark = pinned[branch] && pinned[branch].deploymentId !== d.deploymentId ? '  ⚠ differs from deployments.json' : '';
  console.log(`${kind.padEnd(10)} ${branch.padEnd(32)} v${String(d.versionNumber).padEnd(4)} ${webAppUrl(d.deploymentId)}${mark}`);
}
