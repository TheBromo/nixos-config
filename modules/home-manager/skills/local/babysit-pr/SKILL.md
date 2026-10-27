---
name: babysit-pr
description: Watch a pull request for review comments and failing CI checks, and fix them. Use when the user asks to monitor, watch, or babysit a PR.
---

<!-- Source: https://github.com/t3dotgg/tstack/blob/main/skills/babysit-pr/SKILL.md, changed to react to review comments and failing checks only and never merge -->

# Babysit PR

Watch the PR for review comments from people and review bots and for failing
CI checks, and fix the ones that are right. Do not wait for review bots to
finish, and do not merge. The user merges.

## Waiting

Handle the comments, unresolved threads, and failing checks already on the PR
first. The watcher's first run records them as seen and reports only what comes
after.

Never write your own watcher, polling loop, or `sleep` loop. Use one
watcher per PR: `scripts/pr-wait` from this skill's directory (use its absolute
path). Run it through `python3`: the skill install drops its executable bit.

```bash
python3 <skill-dir>/scripts/pr-wait <pr> [--repo owner/name] --until any-change
```

It prints one line per new event and exits after the first poll that has one.
In Claude Code, run it with the Monitor tool (`timeout_ms: 3600000`), so each
line wakes you. Without a monitor, run it as one long command.

Act only on new comments, reviews, threads, thread replies, and failed checks.
Ignore the other events it reports, such as checks finishing green, a review
bot finishing without comments, or the base branch moving. Then start it
again, also after you push and after a resume. It remembers what it already
reported, so nothing that arrived in between is lost. If it says another pid already watches the PR,
do not start a second one.

When an event needs no action, start the watcher again and end your turn
without a message. Never post or say "still waiting".

Stop when the PR merges or closes, or when the user tells you to.

## GitHub rate limits

`gh pr view` and `gh pr checks` use GraphQL. When GraphQL is used up, the REST
limit is separate and usually still has room. Use
`gh api repos/<owner>/<repo>/pulls/<n>/comments` for review comments,
`gh api repos/<owner>/<repo>/issues/<n>/comments` for top-level comments, and
`gh api repos/<owner>/<repo>/commits/<sha>/check-runs` for checks.

## Fixing failing checks

Read the failed job's log (`gh run view <run-id> --log-failed`) and reproduce
the failure locally when you can. Fix failures the PR caused, push, and start
the watcher again.

Tell repository failures from infrastructure flakes, such as runner timeouts,
network errors, or a check that also fails on the base branch. Re-run a flake
once with `gh run rerun <run-id> --failed`. If it fails again, or the failure
is not caused by this PR, report it to the user instead of changing code.

## Fixing comments

Verify every finding against the source before changing code. Fix real
findings, push, and reply with what changed. When you dismiss a finding, reply
with a written reason and resolve the thread. Use the `leaving-pr-comments`
skill for every comment posted on the user's behalf.

If the repo has `.macroscope/check-run-agents/*.md`, read those rules before you
reply to a Macroscope finding. Its findings cite them.

Keep the PR at the size the user's goal needs. Review loops tend to grow a
PR one cheap-looking fix at a time. Fix real bugs in the intended case.
Decline the rest with a written reason, and list them as follow-ups:
unneeded tests, guards for edge cases that do not matter, extra integration
or compatibility, and small performance costs. Prefer the fix that deletes or
narrows code.

## Merging

Never merge the PR, enable auto-merge, or close it. When the open comments are
handled, tell the user the PR is ready for them to merge.
