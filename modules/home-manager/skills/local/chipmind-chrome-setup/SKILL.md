---
name: chipmind-chrome-setup
description: Set up an authenticated Chipmind Chrome debugger browser context through chrome-devtools MCP. Use before browser debugging or when the isolated browser shows Unauthorized or session-token 403 responses.
---

# Chipmind Chrome debugger setup

Follow the host's browser selection rules; use this Chrome workflow when chrome-devtools
is available and permitted. Use `chipmind-run` when an instance must be started or
restarted; preserve its exact origin and instance-specific paths and ownership.
Read the checkout's `docs/auth.md` to distinguish session-token authentication from SSO.

The parent invokes this skill by assigning its setup workflow to a dedicated subagent.
The assigned setup subagent executes the steps itself without further delegation.
While it owns setup, the parent and other agents leave that browser context untouched.

## Initialize the session

The parent MUST delegate token acquisition, bootstrap exchange, and browser session
initialization to a dedicated subagent as one task: **make the target browser context
authenticated and prove a protected API request succeeds**. Keep credential discovery,
setup commands, retries, and raw auth diagnostics inside that subagent's context.
Give it the checkout, exact origin, target browser context, and instance record/path;
the parent does not read token files or request token values first.

The subagent returns only browser/page identifier, exact origin, auth mode, protected
API path/status, and a short ready/blocked reason. It authenticates the browser in place;
it never hands a token, bootstrap URL, storage dump, or raw setup transcript to the
parent. If delegation or the required child tools are unavailable, reuse an already
authenticated context or report the setup blocker. Do not fall back to acquiring the
token in the main agent's context.

1. Find the running app's actual origin and auth mode. With Chrome, use `list_pages`
   and reuse the app tab, or `new_page` for that origin. Retain its `pageId` for tools
   that accept it, and select it where required. Keep `localhost` and `127.0.0.1`
   distinct: their storage is separate. Prefer an already authenticated context.
2. If session-token mode returns 403, inspect the current checkout's
   `openhands/server/routes/bootstrap.py`, `openhands/server/listen.py`, launcher, and
   `frontend/tests/global-setup.ts`. The server exposes `/_bootstrap_session?bt=…`
   to exchange a launcher-issued, expiring, single-use bootstrap token. It exposes
   **no HTTP endpoint to mint one**; `/_generate_bootstrap_token` is obsolete.
3. Use an unconsumed bootstrap token belonging to this running backend when available.
   `make start-backend` writes `.chipmind_bootstrap_token` in its checkout;
   `make run` passes it through the environment to the browser it opens, which
   normally consumes it. Check the launcher rather than assuming that file exists
   or is current. Read/exchange credentials inside a local helper and seed the target
   browser context programmatically, keeping values out of tool arguments and output.
   The live-test setup demonstrates exchange and storage-state creation; its storage
   file does not authenticate an unrelated MCP browser automatically.
4. If no usable bootstrap or authenticated context exists, return the exact blocker.
   Restart only a debug server this task owns and is authorized to restart, arranging
   for the target browser to receive its bootstrap before another browser consumes it.
   An expired or consumed bootstrap cannot be re-registered in the same server process.
   Keep session authentication enabled. For SSO, use the existing login/cookie flow
   instead of session-token bootstrap; report user-only login steps as blockers.
5. After bootstrap and frontend initialization, verify that localStorage contains
   `chipmind_session_token` by returning a boolean only, then request a relevant
   protected API route from the same context. Attach `X-Session-Token` for manual
   requests in session-token mode. Return only the path/status and readiness result;
   a public health endpoint or a token's presence alone does not prove authentication.

Never print credential values or include them in logs, reports, committed files, or
child handoffs. Redact token-bearing URLs, headers, bootstrap HTML, and storage dumps.
Keep temporary credential artifacts private and remove those created for this task
after use.

