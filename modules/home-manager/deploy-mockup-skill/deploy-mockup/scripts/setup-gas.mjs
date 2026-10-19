// One-time setup: create the shared Apps Script project and write .clasp.json
// (rootDir build/gas). Requires `npx clasp login` first.
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { CLASP_JSON, ROOT, fail, run } from './gas-lib.mjs';

if (existsSync(CLASP_JSON)) fail(`.clasp.json already exists (scriptId ${JSON.parse(readFileSync(CLASP_JSON, 'utf8')).scriptId}). Nothing to set up.`);
const title = process.argv[2] || JSON.parse(readFileSync(join(ROOT, 'package.json'), 'utf8')).name || 'web app';
run('npx', ['--no-install', 'clasp', 'create-script', '--type', 'standalone', '--title', title, '--rootDir', 'build/gas']);
if (!existsSync(CLASP_JSON)) fail('clasp did not write .clasp.json.');
// Keep only what the deploy scripts need.
const { scriptId } = JSON.parse(readFileSync(CLASP_JSON, 'utf8'));
writeFileSync(CLASP_JSON, `${JSON.stringify({ scriptId, rootDir: 'build/gas' }, null, 2)}\n`);
console.log(`\nCreated Apps Script project "${title}" (${scriptId}). Commit .clasp.json, then run \`npm run deploy:gas\`.`);
