---
name: readability-loop
description: Use when the user says "readability loop", or asks to make changed code easier for humans to read through a reviewer loop.
---

# readability-loop

Sol reviews the change for human readability in a loop. You refactor
without changing behavior. The goal is to minimize what a new maintainer
must hold in their head, not to reduce lines or add helpers.

Make the smallest refactors that matter. Avoid scope creep, and push back
when a finding is not worth it.

## Example

Hard to read: compact but opaque.

```python
def calc(u):
    return sum(x["p"] * x["q"] * (0.9 if x["p"] > 100 else 1) for x in u if x["q"] > 0)
```

Easy to read: the intent is explicit.

```python
BULK_DISCOUNT_THRESHOLD = 100
BULK_DISCOUNT_RATE = 0.10


def calculate_order_total(items):
    total = 0
    for item in items:
        if item["quantity"] <= 0:
            continue
        unit_price = item["price"]
        if unit_price > BULK_DISCOUNT_THRESHOLD:
            unit_price *= 1 - BULK_DISCOUNT_RATE
        total += unit_price * item["quantity"]
    return total
```

The second version is longer, but the business rules and conditions are
easy to inspect. Aim for this kind of change.

## Budget

- Default: 3 rounds. Round 1 is full. Later rounds check only changed code
  and open findings.
- Stop early if a round returns only nits.
- Use one reviewer only. Sol must not start subagents.
- Keep a ledger: id, severity, outcome, and usage if returned. Never guess.

## 1. Scope

Follow `sol-loop` §1: run `git status --short`, do not stash or discard,
find the base with `git merge-base`, and use one diff command for all
rounds. Review only changed code. State the intent and what is out of scope
in 1-2 sentences. Run checks (tests, types, lint, format) and record the
results. Note any pre-failing check in the brief.

If the repo already has a metrics tool (`ruff`, `eslint`, `lizard`), run it.
Treat these as flags, not rules: cognitive complexity above 15, functions
above 50 lines, nesting deeper than 3, more than 5 parameters.

## 2. Start Sol

Use the same route as `sol-loop` §2: `orchestrator_capabilities`, the latest
Sol, and `delegate_task` with `role: "review"` and `mode: "async"`, using a
fresh `clientRequestId` each round. If no route runs Sol, report the blocker
and do not substitute a model. Do not edit scoped files while the review
runs. Wait for the notice and do not poll.

Round 1 brief:

```
Review only. Do not edit, commit, push, comment on PRs, or start subagents.
Repo: <abs path> Base: <sha> Intent: <intent> Out of scope: <scope> Checks: <results>
See: git diff <base> [-- <paths>]; git status --short (read untracked files).
Read the code as a developer seeing it for the first time. Read surrounding
code and match repo conventions. Find comprehension barriers in changed code only:
- names that hide intent, vague abbreviations, inconsistent domain terms
- functions doing more than one job, dense one-liners, deep nesting (prefer guard clauses)
- hidden state, side effects, implicit error handling
- magic numbers; unnecessary abstractions, helpers, or layers
- comments that repeat the code; missing "why" on non-obvious choices or invariants
- tests that do not show expected behavior
Every refactor must preserve behavior and public interfaces. Do not add
length or abstraction without a clear gain. Skip cosmetic or taste-only items.
Example of the target: `calc(u)` as one dense sum() becomes
`calculate_order_total(items)` with named constants, a guard clause, and a plain loop.
blocker = a reader will likely misread the behavior.
should = a real mental cost that the fix clearly reduces.
nit = everything else.
Reply:
VERDICT: APPROVE or CHANGES
R1 [blocker|should|nit] <file>:<line> <barrier>. Why hard: <reason>. Fix: <simpler form> (stable ids)
Finally, explain the data flow in 3 lines as a new maintainer would. If that
is hard, say so and where.
```

## 3. Answer findings

Judge each finding yourself. Taste, rare paths, or extra length without a
gain count as nits.

- Agree: make the smallest behavior-preserving refactor. Prefer a rename,
  inline, guard clause, named constant, or deletion over a new helper or
  class.
- Disagree: explain why with evidence (file:line, a convention elsewhere).
- Nit or out of scope: decline in one line and list it as a follow-up.

Re-run all checks after each round. If a check fails, the refactor changed
behavior: revert or fix it before the next round. Watch
`git diff --shortstat <base>`; the review must not bloat the diff.

## 4. Next round

Start one only if budget remains and a blocker or should is open, or code
changed since the last approval. Send the round 1 brief, the ledger
(`fixed:` / `disagree:` / `declined:` with evidence), and the change since
the last round. Tell Sol to check only open ids and changed code, and to
mark each old id `resolved` or `still open: <reason>`.

## 5. Stop

Done: Sol approves the current diff, no blocker or should is open, and checks
pass. Stuck: an item stays disputed after two replies, or the budget runs
out. Show both sides in 2-3 lines each and let the user decide. Running out
of budget is not approval. Do not push unless the user asked.

Report: rounds, model, refactors made, declined findings with reasons, diff
size before and after, check results, Sol's data-flow summary, and usage if
exposed.
