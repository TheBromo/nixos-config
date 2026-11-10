---
name: chipmind-debug
description: Diagnose and fix Chipmind application bugs, including backend failures, UI reproduction, console and network inspection, and verification after a fix.
---

# Chipmind debugging

Use `diagnosing-bugs` for the reproduction and fix loop. Read the checkout's
`docs/backend-debugging.md` for backend attach debugging and the relevant architecture,
router, service, and test documentation for the failing behavior.

Use `chipmind-run` when an instance must be started or restarted; keep its exact
origin and instance-specific state, runtime prefix, and process ownership throughout.
For Chrome debugger browser initialization, Unauthorized pages, or session-token 403
responses, delegate `chipmind-chrome-setup` to a dedicated subagent. That skill owns
credential acquisition and browser authentication; continue with its authenticated
browser context and sanitized readiness result. Keep raw setup work out of the parent
context. Follow the host's browser selection rules.

## Delegate bounded work

Delegate one-off tasks with a clear completion criterion whenever the child has the
required tools and access. Give it the checkout, origin, target conversation, scope,
and expected output. The parent owns diagnosis, integration, and final verification.

| Task | Child's output |
| --- | --- |
| Browser setup via `chipmind-chrome-setup` | Sanitized readiness result defined by that skill |
| Trace a failing request through backend handlers | Route-to-service call path with file/line evidence and relevant tests |
| Capture one UI reproduction | Exact steps, expected/actual result, redacted console/network evidence |
| Run a focused regression check | Command, exit status, relevant result, artifact paths if any |

Serialize tasks that navigate the same browser tab, mutate the same files, or control
the same server. While a child owns session setup or UI reproduction, keep the parent
off that browser context. Parallelize independent source inspection instead. If child
tools or shared browser access are unavailable, perform non-credential tasks directly
and report that limitation. Credential setup follows `chipmind-chrome-setup`'s stricter
subagent requirement. A child completes its assignment itself without further delegation.

## Reproduce and verify

Navigate to the desired conversation, inspect with `take_snapshot`, and reproduce the
reported interaction. Use fresh console and network evidence to identify the failing
request or UI state; use `evaluate_script` for focused DOM/state inspection.

After a fix, reload, repeat the original interaction, and verify its rendered result
and fresh console/network evidence alongside the focused regression check.
