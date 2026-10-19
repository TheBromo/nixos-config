// Build the app for Google Apps Script: one self-contained index.html, plus
// Code.gs (with build info) and the manifest, in build/gas (clasp's rootDir).
import { mkdirSync, readFileSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { pathToFileURL } from 'node:url';
import { GAS_OUT, PRODUCTION_BRANCH, ROOT, commitInfo, currentBranch, run } from './gas-lib.mjs';

/** Apps Script stores files in the project; keep well clear of its per-file limits. */
const WARN_BYTES = 8 * 1024 * 1024;

export function buildGas(branch = currentBranch()) {
  const { sha, dirty } = commitInfo();
  console.log(`Building for Apps Script: ${branch} @${sha}${dirty ? ' (uncommitted changes)' : ''}`);
  run('npx', ['--no-install', 'vite', 'build', '--mode', 'gas', '--logLevel', 'warn']);

  rmSync(GAS_OUT, { recursive: true, force: true });
  mkdirSync(GAS_OUT, { recursive: true });

  // No other files are served, so a favicon link would only 404.
  const html = readFileSync(join(ROOT, 'build', 'gas-web', 'index.html'), 'utf8').replace(/\s*<link rel="icon"[^>]*>/, '');
  writeFileSync(join(GAS_OUT, 'index.html'), html);

  // HtmlService sets the tab title itself; take it from the page.
  const title = html.match(/<title>([^<]*)<\/title>/)?.[1]?.trim() || 'App';
  const build = { title, branch, commit: sha, dirty, production: branch === PRODUCTION_BRANCH, builtAt: new Date().toISOString() };
  const code = readFileSync(join(ROOT, 'gas', 'Code.gs'), 'utf8').replace('__BUILD__', JSON.stringify(build));
  writeFileSync(join(GAS_OUT, 'Code.gs'), code);
  writeFileSync(join(GAS_OUT, 'appsscript.json'), readFileSync(join(ROOT, 'gas', 'appsscript.json')));

  const size = statSync(join(GAS_OUT, 'index.html')).size;
  console.log(`build/gas: index.html ${(size / 1024 / 1024).toFixed(2)} MB, Code.gs, appsscript.json`);
  if (size > WARN_BYTES) console.warn(`⚠ index.html is ${(size / 1024 / 1024).toFixed(1)} MB; Apps Script may refuse very large files.`);
  return build;
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) buildGas();
