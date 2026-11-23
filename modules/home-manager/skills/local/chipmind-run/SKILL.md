---
name: chipmind-run
description: Start, reuse, or stop a local Chipmind development instance, including concurrent instances on one machine with isolated ports, state, runtime containers, and cleanup.
---

# Run a Chipmind instance

Deliver a reachable instance of the requested checkout without disturbing other runs.
Read that checkout's Makefile, `scripts/run_app.sh`, `docs/backend-debugging.md`, and
the relevant config/runtime code before choosing overrides; names below describe the
current implementation and must be checked against the checkout.

Delegate startup as a bounded task whenever the child can launch a process that
survives its handoff. Give it the checkout, required runtime/features, and ownership
scope. Its output is the checkout/commit, instance identifier, backend/frontend URLs,
runtime, state/config/workspace paths, readiness result, log path, and durable process
handle plus exact stop procedure. Return credential paths only, never values. If the
child cannot retain a durable process, launch in a parent-owned terminal instead;
delegate independent prerequisite/port inspection. Children finish without delegation.

## Identify and isolate

1. Check existing listeners and known run records. Reuse an instance only after matching
   its checkout, configuration, and required features. A responding port alone is not
   enough. Choose an instance identifier unique among active runs.
2. Allocate distinct free backend, frontend, and optional debugpy ports. Probe binding
   on the chosen interface immediately before launch. Allocation is racy: if startup
   loses a port, pick another and update every reference rather than stopping its owner.
   Keep one exact browser origin, including hostname and port, throughout auth and tests.
3. Give the instance a private runtime directory outside tracked source. Keep its config,
   state, cache, workspace, bootstrap file, PID record, logs, and run metadata there.
   Use owner-only permissions for config and credential artifacts. Preserve the real
   HOME so dependencies and credentials resolve normally.
4. Set `STATE_DIR` to the private state path. This isolates the default SQLite database,
   conversations, settings, and process-sandbox registry. Verify both core and app-server
   storage resolve there. Inspect inherited `DB_*`, `GCP_DB_*`, `SHARED_EVENT_STORAGE_PROVIDER`,
   `FILE_STORE`, and `OH_*` overrides: a shared external database/cloud store or explicit
   injector can bypass local state isolation. Use instance-specific storage or remove
   those overrides only in the child environment when local storage is intended.
   Inspect dotenv loading too: a checkout's `.env` can restore values removed from the
   launch environment. When the task supplies all needed settings explicitly, use
   `PYTHON_DOTENV_DISABLED=1` to keep repository dotenv files from reintroducing them.
5. Use a private configuration selected with **both** Make's `CONFIG_FILE` and backend
   `OPENHANDS_CONFIG_FILE`. Keep the source checkout's config untouched. Configure an
   instance-specific writable workspace via `[sandbox]` mounts or local workspace path;
   `WORKSPACE_BASE` alone does not replace an explicit sandbox mount. Copy only the
   settings needed for the task; keep session authentication enabled in session-token mode.
6. Override `BACKEND_PID_FILE` and `BOOTSTRAP_TOKEN_FILE` on Make's command line, even
   for concurrent runs from the same checkout. The defaults are checkout-wide. Separate
   source checkouts also avoid concurrent frontend builds and generated-file writes;
   if sharing a checkout, serialize those operations and keep build/config inputs equal.

`make run-local` selects HTTP ports but still shares config/state/PID files and can
reconfigure the bundled Keycloak service. It is not a substitute for this isolation.

## Choose runtime and launch

- For UI/API work without EDA requirements, use Docker sandboxes with `EDA_PROVIDER=none`,
  or the process runtime (`RUNTIME=local`) if the task and host tools support it. A running
  UI alone does not establish that tool execution or a real conversation works.
- For Docker sandboxes, set a unique `SANDBOX_CONTAINER_NAME_PREFIX` for each instance.
  The default prefix shares container discovery/reaping across app servers. Check explicit
  sandbox injector settings too: they may bypass the environment fallback. Build/reuse
  the sandbox image matching the checkout and avoid concurrent writes to a shared image tag.
- The EDA container defaults to the fixed name `edacontainer`, also baked into sandbox
  tool wrappers. Changing only `EDA_CONTAINER_NAME` leaves wrappers pointing at the wrong
  container. For EDA-dependent work, inspect and coordinate an existing compatible EDA
  service with matching workspace mounts, or configure/build matching wrappers and an
  instance-specific EDA container. Never replace another run's EDA container to start yours.
- Process sandboxes use host tools and additional ports. Verify available tool binaries,
  workspace isolation, and the checkout's port-lock behavior. App HTTP ports alone are
  not the full runtime port allocation. Native runs need `tmux` and `openvscode-server`;
  model/Git settings may need configuration in the new state directory. Per-user tmux,
  sandbox temp trees, and port locks remain shared; never delete their shared roots.

Use a durable managed terminal/process session and retain its handle. A `make run`
shape after paths and ports have been selected is:

```sh
env STATE_DIR="$instance_dir/state" CACHE_DIR="$instance_dir/cache" \
  OPENHANDS_CONFIG_FILE="$instance_dir/config.toml" \
  SANDBOX_CONTAINER_NAME_PREFIX="chipmind-$instance_id-" \
  make run USE_VITE=1 EDA_PROVIDER=none \
  CONFIG_FILE="$instance_dir/config.toml" \
  BACKEND_HOST=127.0.0.1 BACKEND_PORT="$backend_port" \
  BACKEND_DEV_PORT="$frontend_port" \
  BACKEND_PID_FILE="$instance_dir/backend.pid" \
  BOOTSTRAP_TOKEN_FILE="$instance_dir/bootstrap-token"
```

This example requires Docker and intentionally omits EDA; select the runtime the task
needs. `make run` auto-opens and bootstraps a browser. For an isolated debugger browser,
delegate `chipmind-chrome-setup` to arrange authentication in that exact context. If using separate
`start-backend` / `start-frontend` sessions instead, pass matching overrides to both and
retain both process handles. The standalone backend writes the private bootstrap file.
Ensure Vite targets the selected backend and uses the requested frontend port; enable
strict port binding or verify its actual port rather than accepting a silent fallback.

For attach debugging, add `DEBUG_BACKEND=1 DEBUG_PORT="$debug_port"`. The backend waits
for a debugger before app readiness, so attach/continue before judging startup failed.

## Verify and stop

Wait with bounded readiness probes while checking the owned process is alive. Discover
the checkout's health routes rather than assuming `/ready` exists: the current server
exposes `/alive` and `/health`. These establish liveness only. Verify the frontend's
actual origin and API proxy, then a protected API call after authentication to establish
application readiness. If the task needs conversations/tools, perform a minimal relevant
runtime operation as well. Record redacted errors if readiness fails; stop only the failed
run's owned processes before retrying. Keep a non-secret run record with all selected
paths, ports, process handles, and cleanup instructions for later handoff.

Stop via Ctrl-C in the owned Make terminal (or its managed equivalent), allowing the
launcher to clean up its children and sandboxes. With standalone services, stop each
recorded process deliberately. Confirm the owned listeners are gone and other instances
remain reachable. Use recorded ownership and process identity before escalating signals;
never kill by a broad name/port pattern or run machine-wide Docker cleanup. Remove only
this instance's temporary artifacts after processes exit; retain requested logs or state.
