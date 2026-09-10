---
name: chipmind-debug
description: Debug the local ChipMind application with the chrome-devtools MCP, including browser session initialization, UI reproduction, console and network inspection, and verification after a fix. Use when investigating ChipMind UI issues or Unauthorized responses in the isolated MCP browser.
---

Debug the local application with the `chrome-devtools` MCP:

1. Use `list_pages` to find the application tab, or `new_page` to open `http://127.0.0.1:3001`. Pass its `pageId` to subsequent calls.
2. If the page shows **Unauthorized** and `/api/*` requests return **403**, initialize this browser’s session. The MCP browser has separate storage from the user’s browser. Run this with `evaluate_script`:

```js
async () => {
  const response = await fetch('/_generate_bootstrap_token');
  if (!response.ok) throw new Error(`Bootstrap failed: ${response.status}`);
  const { bootstrap_token } = await response.json();
  location.replace(
    '/_bootstrap_session?bt=' + encodeURIComponent(bootstrap_token)
  );
}
```

3. Let the redirect finish, then use `navigate_page` to open the desired conversation. The bootstrap endpoint exchanges the one-time token, stores `chipmind_session_token` in localStorage, and redirects into the application. Frontend requests automatically attach `X-Session-Token`.
4. Inspect the UI with `take_snapshot`, reproduce the issue with `click` or keyboard tools, and inspect `list_console_messages` and `list_network_requests`. Use `evaluate_script` to examine DOM elements, IDs, and application state.

For manual API requests inside `evaluate_script`, supply:

```js
headers: {
  'X-Session-Token': localStorage.getItem('chipmind_session_token')
}
```

Never print tokens or include them in logs, reports, or committed files. Use the same origin throughout: `localhost` and `127.0.0.1` have separate storage.

After a fix, reload the page, repeat the interaction, and verify both the rendered result and fresh console messages.
