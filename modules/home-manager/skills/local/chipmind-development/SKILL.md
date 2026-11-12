---
name: chipmind-development
description: Select developer workflows when working on the Chipmind repository, including backend, frontend, Chipgraph, and RTL Canvas investigations.
---

# Chipmind developer skills

Use the active Chipmind checkout's docs and code as the source of truth. The root
`skills/` and `subagents/` directories describe Chipmind's product agents, not the
coding agent developing the application.

For development and testing, use the local process runtime. Follow `chipmind-run`
for runtime selection and isolated launch commands; use Docker only when the task
explicitly calls for container behavior or deployment.

| Task | Skill and repository context |
| --- | --- |
| Start, reuse, or stop an app instance | `chipmind-run`; inspect the checkout's Makefile and `scripts/run_app.sh` |
| Browser authentication and Chrome debugger initialization | `chipmind-chrome-setup` via a dedicated subagent |
| Diagnosis, browser reproduction, console/network evidence | `chipmind-debug` |
| Build a failing reproduction and diagnose its cause | `diagnosing-bugs`; read relevant backend/frontend test guidance |
| Python backend, CLI, tools, or evaluations | `python`; read `docs/backend-architecture.md` and the relevant app-server README |
| TypeScript/frontend changes | `typescript`, `vercel-react-best-practices`; finish with `react-doctor` |
| Explorer search failure from a conversation export | Read `.agents/skills/explorer-failure-to-eval/SKILL.md` if present and `evaluations/chipgraph_search/README.md` |
| Chipgraph query or builder investigation | Read `docs/chipgraph.md`, `chipgraph-builder/README.md`, and `subagents/explorer.md` |
| RTL Canvas/diagram investigation | Read `docs/rtl/rtl-canvas.md`, `docs/rtl/rtldrawoverview.md`, and `subagents/illustrator.md` |
| Auth or request routing | `chipmind-debug`; read `docs/auth.md`, bootstrap routes, and the relevant router/service |
| A difficult module boundary or test seam | `codebase-design`; use `domain-modeling` for terminology or ADR changes |
| Requested branch review or security investigation | `code-review` or `review`; use `security-audit` for security work within its requested scope |

Delegate bounded one-off work whenever the child has the needed tools and access:

- Export extraction → original search prompt, report, metadata, event references.
- Graph fact check → exact query, observed facts, design/commit, discrepancies.
- Request trace → route-to-service path, file/line evidence, relevant tests.
- Focused reproduction → command, redacted output, verdict, artifact paths.
- Instance startup or browser authentication → the output contracts in `chipmind-run`
  and `chipmind-chrome-setup`.

Give each child the checkout, inputs, scope, and completion criterion. The parent
checks evidence, chooses the fix, integrates changes, and verifies the original bug.
Serialize shared browser/server mutations, case edits, and taskset regeneration;
parallelize independent read-only investigations. Children finish their assigned tasks
without recursive delegation. If delegation tools/access are unavailable, perform only
non-credential tasks directly and state the limitation. For browser authentication,
reuse an already authenticated context or report the setup blocker; keep token
acquisition and session initialization inside the dedicated setup subagent.
