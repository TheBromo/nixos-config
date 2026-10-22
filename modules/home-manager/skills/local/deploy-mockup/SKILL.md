---
name: deploy-mockup
description: Deploy Vite mockups and single-page apps to Google Apps Script with stable URLs per Git branch. Use for Apps Script hosting, clasp deployment setup, Google Workspace branch previews, or maintaining an existing deploy-mockup integration.
---

# Branch deployments of a Vite app on Google Apps Script

Result: `npm run deploy:gas` on any branch prints that branch's web app URL.

- A branch's first deploy creates a deployment, so it gets a new URL.
- Later deploys move the same deployment to a new immutable version, so the URL stays.
- Other branches are never touched.
- `main` keeps its production URL across redeploys while its deployment exists.
- With the supplied CI workflow, deleting a branch archives its deployment.

The model: **one shared Apps Script project, one versioned deployment per branch.** Each deployment points at an immutable version, so branches stay isolated even though they share the project's working source.

## What's in this skill

- `scripts/`: copy these into the target project's `scripts/` folder and adapt them to its build tooling.
  - `gas-lib.mjs`: shared helpers (branch detection, clasp calls with JSON output, the lock, the registry).
  - `build-gas.mjs`: builds the single-file page into `build/gas/`.
  - `deploy-gas.mjs`: deploys the current branch.
  - `list-gas.mjs`: lists branch deployments with their URLs.
  - `cleanup-gas.mjs`: archives a branch's deployment.
  - `setup-gas.mjs`: creates the Apps Script project once.
- `templates/`:
  - `Code.gs` and `appsscript.json`: copy into the project's `gas/` folder.
  - `deploy-gas.yml`: copy into `.github/workflows/`.
  - `frame.html`: the local sandbox check from step 3.

## Workflow

### 1. Inspect the app before changing anything

Apps Script serves exactly **one HTML page and nothing else**: no static files, no `/assets`, no `public/` folder. Look for everything the app loads at runtime from its own server:

- `fetch()` of files in `public/` (data, SVG, JSON);
- favicons;
- web workers loaded from URLs;
- lazy-loaded routes;
- fonts referenced by URL.

Each of these must be bundled into the page or removed. Assets on external CDNs and Google Fonts still work.

A typical fix keeps dev unchanged and bundles the file only in the Apps Script build:

```ts
const loadSource = (): Promise<string> =>
  import.meta.env.MODE === 'gas'
    ? import('../../public/source.svg?raw').then((m) => m.default)
    : fetch(`${import.meta.env.BASE_URL}source.svg`).then((r) => r.text());
```

### 2. Single-file build (`--mode gas`)

Run `npm i -D --save-exact vite-plugin-singlefile @google/clasp` (clasp 3), preserving the project's package manager. Then make `vite.config.ts` mode-aware:

```ts
import { viteSingleFile } from 'vite-plugin-singlefile';
export default defineConfig(({ mode }) => ({
  plugins: [/* existing */, ...(mode === 'gas' ? [viteSingleFile({ removeViteModuleLoader: true })] : [])],
  ...(mode === 'gas' ? { publicDir: false as const, build: { outDir: 'build/gas-web', emptyOutDir: true, chunkSizeWarningLimit: 4096 } } : {}),
}));
```

The normal `vite build` and dev server stay as they were. Copy the scripts and templates, then add these package.json scripts:

```json
"build:gas": "node scripts/build-gas.mjs",
"deploy:gas": "node scripts/deploy-gas.mjs",
"deployments:gas": "node scripts/list-gas.mjs",
"cleanup:gas": "node scripts/cleanup-gas.mjs",
"setup:gas": "node scripts/setup-gas.mjs"
```

Add `build` and `.clasprc.json` to `.gitignore`.

`build-gas.mjs` writes three files to `build/gas/` (clasp's `rootDir`):

- `index.html`, with the favicon link removed;
- `Code.gs`, with `__BUILD__` filled in: the page title, branch, commit and whether it's production;
- `appsscript.json`.

`Code.gs` serves the page with `HtmlService.createHtmlOutputFromFile('index')`. The title and viewport come from `.setTitle()` and `.addMetaTag('viewport', …)`, because HtmlService ignores the page's own viewport meta. Use `createHtmlOutputFromFile`, not a template: templates evaluate `<? ?>`, and bundled content such as `<?xml` would break them.

### 3. Verify the build locally before touching Google

Run `npm run build:gas`, then check `build/gas/index.html`:

- **No outside references:** grep for `src="/`, `href="/` and `./assets/`; nothing should remain.
- **Bundled files are inside:** inlined fonts appear as `data:font/woff2` and inlined data files as their content.
- **It runs sandboxed:** copy `templates/frame.html` next to `index.html`, serve the folder (`python3 -m http.server`), and open `frame.html`. Verify rendering and that every request is either the page itself or an intentionally retained external HTTPS resource. This approximates the sandbox; verify the real deployment separately.

Also run the normal `vite build` to check it still works.

Pushing first and debugging remotely is slow, because every push costs a version.

### 4. Choose who can open the URLs

Honor the user's existing access choice; if none is specified, default to `DOMAIN` so users in their Workspace domain can open the URLs. Use this default without asking for an access choice.

`webapp.access` in `gas/appsscript.json` takes one of:

- `DOMAIN`: the default, the user's Workspace domain;
- `MYSELF`: only the deploying user;
- `ANYONE`: any Google account;
- `ANYONE_ANONYMOUS`: anyone with the link.

Keep `"executeAs": "USER_DEPLOYING"`. The template is shared by branches, but versioned deployments retain their deployed configuration; changing the source manifest alone does not update existing URLs. Verify the intended access on each updated deployment.

### 5. Steps only the user can do

These are interactive or tied to their account, so the user does them, not you:

1. **Enable the Apps Script API** at https://script.google.com/home/usersettings. Without it every clasp API call fails.
2. **Log in:** have them run `npx clasp login` in their terminal. Then confirm with `npx clasp show-authorized-user`. Reuse an existing authorized session when available.

### 6. Create the project, then deploy production

1. Run `npm run setup:gas -- "Project title"` (omit the argument to use `package.json`'s name). It runs `clasp create-script` and keeps only `{scriptId, rootDir: "build/gas"}` in `.clasp.json`.
2. **Commit `.clasp.json` before deploying `main`.** The script ID is not a secret, and the deploy refuses a `main` with uncommitted changes (`--allow-dirty` overrides).
3. Run `npm run deploy:gas`. It runs the steps below under a lock:
   1. `build-gas`;
   2. `clasp push --force`;
   3. `clasp --json create-version "<branch> @<sha>"`;
   4. it finds the deployment described `branch:<branch>`;
   5. if one exists, `clasp --json update-deployment <id> --versionNumber N --description branch:<branch>`; if not, `clasp --json create-deployment …`;
   6. it prints `https://script.google.com/macros/s/<id>/exec`.
4. The first `main` deploy writes `deployments.json` with the production ID. **Commit it.**
5. Deploy `main` once more and check the URL is unchanged (version 1 → 2). That proves the update path.

**Checking the URL in a browser:** with `MYSELF` or `DOMAIN` access, an automated browser that isn't signed into Google lands on the Google sign-in page. That is the expected access control, not a broken deploy. Don't type credentials. Ask the user to open the URL in their own signed-in browser, and verify on the server side with `npm run deployments:gas`.

### 7. CI (GitHub Actions)

Copy `templates/deploy-gas.yml`. It:

- deploys on every push, after the type check and tests;
- archives a branch's deployment on the `delete` event, which needs `github.event.ref`: `GITHUB_REF_NAME` is the default branch on delete events;
- shares one `concurrency` group with `cancel-in-progress: false`.

Adapt the Node version, package manager, typecheck and test commands to the target project. GitHub concurrency allows one running and one pending run by default; newer pushes can replace pending runs, so this does not guarantee every commit is deployed. For reliable branch deletion cleanup, retain manual `cleanup:gas -- --prune --dry-run` and `cleanup:gas -- --prune` commands.

It needs a repository secret `CLASPRC_JSON` with the contents of `~/.clasprc.json`. Tell the user these are their personal credentials and CI will act as them; suggest a dedicated Google account. If the repository has no remote yet, say that CI can't run until it does.

Finally, write a short `DEPLOY.md` for the project: the setup steps, the commands, and the caveats below.

## Why the scripts work this way

These are the decisions most likely to get "simplified" by mistake.

- **The deployment description is the registry.** `branch:<name>` lives in Apps Script, so every machine and CI run sees the same mapping. A committed JSON file per branch would diverge between branches and cause merge conflicts. `deployments.json` only *pins production*: if the pinned deployment is missing, the deploy fails instead of silently creating a new production URL.
- **`clasp --json` (a global flag, before the command), parsed from the first `{` or `[` line.** Text output changes between clasp versions. `list-deployments` also returns the `@HEAD` deployment, which has no version number; skip it. Two deployments with the same branch description is an error, not a guess.
- **clasp 3 command names:** `create-version`, `create-deployment`, `update-deployment`, `list-deployments`, `delete-deployment`, `create-script`. The old names (`version`, `deploy`, `redeploy`, …) still work as aliases.
- **`clasp push --force`:** without it, clasp may skip pushing when the manifest changed.
- **Lock around push → version → deploy:** `push` replaces the shared working source, so two deploys interleaving would version the wrong code. The lock is a local `O_EXCL` lock file per script ID, taken over if its process is dead or it's older than 20 minutes. CI is serialized by the workflow's concurrency group. A laptop deploy and a CI deploy at the same moment are *not* serialized, so once CI exists, recommend deploying only from CI.
- **Cleanup never archives production:** it skips the production branch and any ID pinned in `deployments.json`. `--prune` archives the deployments whose branch is gone from `origin`; `--dry-run` previews it.

## Caveats to tell the user

- **Versions:** Apps Script keeps at most 200 per project, and every deploy adds one. The script warns from version 180. Old versions can only be deleted by hand in the Apps Script editor (Project history), so frequent CI deploys of many branches use them up.
- **Shared project:** branches share access, OAuth scopes, quotas and the owning account. Branches that need different settings need separate projects.
- **Browser storage:** `localStorage` works inside the sandboxed iframe, but on a Google-chosen origin. Don't promise that previews and production keep separate saved data. Browsers that block third-party storage start empty on every visit.
- **Size:** bundled data makes the page large (a few MB is fine). The build warns above 8 MB.

## Report back

Creating or installing this skill does not authorize a live deployment. When invoked for a deployment, stay within the user's requested project and audience. If a remote operation fails, inspect the branch mapping before retrying; avoid creating extra versions or replacement production URLs blindly.

Tell the user:

- the production URL;
- which deploy paths were proven (create, then update with the same URL) and which weren't (a feature branch, CI);
- the access setting in effect;
- what's still needed from them, such as the CI secret or a git remote.

For provider behavior or changed CLI versions, check the primary references: [Apps Script deployments](https://developers.google.com/apps-script/concepts/deployments), [web app access](https://developers.google.com/apps-script/manifest/web-app-api-executable), [version limits](https://developers.google.com/apps-script/guides/versions), [clasp](https://github.com/google/clasp), and [GitHub concurrency](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency).
