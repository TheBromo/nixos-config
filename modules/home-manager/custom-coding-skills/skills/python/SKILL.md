---
name: python
description: Python with full typing, explicit contracts, and uv-run lint/type checks. Use when writing, refactoring, or reviewing Python code.
---

# Python

Expose data shapes, decisions, effects, and failures where readers encounter them.

## Workflow

1. Read repository guidance, tool configuration, callers, and tests until affected contracts and checks are known.
2. Apply these rules across the requested scope. Separate behavior changes from readability edits; report review findings with locations and consequences.
3. Complete the uv validation loop below. Report commands, failures, enforcement gaps, and unverified behavior.

## Types are the contract

- Fully type all new or changed code, including private helpers, constructors, tests, fixtures, callbacks, and decorators. Annotate every parameter and return, including `-> None`; implicit `self`/`cls` types are sufficient.
- Annotate fields, module state, and ambiguous locals. Other locals must have complete inferred types. Parameterize collections, callables, generators, and async results; preserve decorator signatures.
- Use `object` plus narrowing for unknown input. Confine unavoidable `Any`, reflection, and version probes to documented adapters; expose fully typed results.
- Give each stable contract one owner. Reuse existing models, enums, constants, and codecs across producers, consumers, and tests.
- Model closed vocabularies with `Enum`/`StrEnum` or `Literal`; represent variants as discriminated unions. Use `assert_never` to make exhaustive dispatch type-checked.

- Validate external payloads, including their outer shape. Pass typed data inward: dataclasses for records, `TypedDict` for dictionary contracts, validation models for untrusted input.
- Casts do not validate. Keep parsing and rendering of composite identifiers, keys, and paths in one codec.
- Preserve missing, `None`, empty, zero, and false distinctions. Use `is None` for absence-only defaults.
- Name ambiguous result fields. Use keywords for ambiguous flags and long calls; group parameters by domain concept.

## Functions and branches

- Call straightforward APIs directly. Avoid trivial forwarding helpers such as `get_time_utc()` containing only `return time.utc()`.
- A one-line function earns its place through a required interface, meaningful policy, or deliberate dependency seam. Line count alone does not justify extraction.
- Hoist identical setup before an `if` when both branches require it. Load `env = load_env_var()` once, then branch on differing behavior.
- Preserve evaluation order, call count, exception boundaries, and conditional execution when hoisting. Keep branch-specific work inside its branch.
- Extract coherent policies or I/O phases with explicit results. Forwarding unrelated arguments through another helper hides coupling.
- Use guard clauses for terminal states. Expand chained conditionals when precedence or fallback policy obscures meaning.
- Use comprehensions for one transformation or filter; loops for state, recovery, and effects.
- Separate pure policy from I/O. Search existing utilities before adding one; reconcile contracts before consolidating duplicates.
- Preserve justified lazy imports and startup ordering. Keep SDK patches explicit, ordered, and idempotent; inspect package import effects.

## Dependencies and output

- Resolve environment, cwd, clock, randomness, and host paths at entrypoints. Pass typed snapshots inward; inject behavior through small consumer-owned `Protocol`s or typed callables.
- Keep CLI/request handlers thin: parse, validate, call domain logic, render. Use concrete result models; group inseparable contract attributes instead of parallel maps.
- Serialize typed records once at the output boundary. Use structured logging with context; keep secrets and raw sensitive payloads out.

## Failures and lifecycle

- Catch expected failures where recovery occurs. Broad catches need an isolation policy, diagnostic context, and defined fallback or reraise.
- Use typed exceptions for branchable failures; never match exception messages. Translate foreign errors at boundaries and preserve causes with `raise ... from ...`.
- Preserve traceback chaining, HTTP responses, and swallowed-failure behavior during readability edits.
- Identify transaction, resource, and task owners before moving effects. Guarantee cleanup through context managers or `finally`.
- Enforce deadlines through the final wait. Await owned tasks and cancellation cleanup. Cancelling an awaiter does not stop its worker thread.

## Readability and tests

- Distinguish domain roles in names. Comments explain invariants and reasons; remove statement narration and distracting incident history.
- Keep suppressions inline, rule-specific, and justified. Fix typing defects rather than widening to `Any` or disabling checks.
- Test outcomes and contractual boundary interactions with realistic failures and interface-constrained mocks.
- Cover sentinel distinctions, invalid shapes, failure versus emptiness, and required ordering.
- Use deterministic fakes, temporary paths, and parametrized cases. Assert typed outcomes; test raw wire spellings independently at boundaries.
- Synchronize async tests with events or barriers and bounded waits. Await intended suspensions; prove startup, timely return, and owned-work cleanup.

## Required uv validation

For every Python change, run formatting, lint, and type checks over touched code and affected interfaces. Ruff checks annotations; a type checker checks their correctness. Both are required.

Prefer repository-pinned tools and configuration. With a uv lockfile, run these templates using actual paths:

```sh
uv run --locked ruff format --check <paths>
uv run --locked ruff check --extend-select ANN <paths>
uv run --locked mypy --strict <paths>
uv run --locked pytest <relevant-tests>
```

Use the repository's configured type checker instead of mypy when established; require equivalent strict coverage. Supply its config path when discovery needs it. Run behavioral tests when warranted.

Without project tooling, use `uvx ruff` and `uvx mypy`; select compatible versions and supply required stubs/plugins. Isolated tools must resolve project dependencies for valid results.

Treat lint/type configuration as part of the contract. Check effective settings: ignored imports, skipped functions, and permissive overrides can hide untyped code. Add scoped enforcement where appropriate; report remaining gaps. Never relax checks to claim success.

Fix introduced diagnostics and rerun affected checks. Distinguish pre-existing failures from regressions. Report unavailable tools explicitly; never substitute a formatting pass for type checking. Preserve dependency pins and report intentional dependency/config changes.
