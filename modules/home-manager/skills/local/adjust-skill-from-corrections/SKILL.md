---
name: adjust-skill-from-corrections
description: Update a custom coding skill using the user's corrections in the current conversation. Use when asked to capture feedback, remember corrected coding preferences, or reconcile a skill with how the user corrected the agent's work.
---

# Adjust a skill from corrections

Turn the user's corrections in the available conversation into focused, reusable skill edits. Follow [edit-custom-skills](../edit-custom-skills/SKILL.md) for source discovery, editing, packaging, and validation from any working directory.

## Identify the correction

Read the relevant conversation and inspect corrected code or diffs when available. Identify what the agent originally did, what the user wanted instead, and the conditions under which that distinction matters. Treat the user's statements and edits as evidence; the agent's own suggestions are not user preferences unless the user adopted them.

Use the latest explicit correction when the user revised an earlier preference. Preserve meaningful scope: a requirement for one API, framework, or project should remain conditional. Distinguish a lasting preference from a temporary workaround or a factual bug fix. If the conversation lacks the correction being referenced, ask for that missing detail rather than inventing it.

Infer the target skill from the user's request, language, and corrected behavior, then read its source and related examples. If several skills are plausible and placement would change their behavior, ask which should own the rule. If no suitable custom skill exists, propose its scope and ask before creating it; a request to adjust a skill alone does not select a new skill's scope.

## Integrate the lesson

Write the desired behavior positively with its trigger and constraints. Replace or refine the rule that caused the mismatch, keeping one authoritative statement. Reconcile contradictory examples and references within the requested scope. Preserve unrelated guidance and avoid appending a chronological transcript or a list of past mistakes.

Generalize only as far as the correction supports. For example, “hoist this environment read because both branches need it” supports sharing identical required setup while preserving call count and execution order; it does not establish that every environment read belongs at startup.

Add or revise a supporting example when requested or when prose alone leaves the corrected decision ambiguous. Keep examples inside the target skill, link them from the relevant rule, and validate executable code with the language's checks.

## Complete the change

Apply the shared editing workflow's checks and review the diff against the user's actual corrections. Report the correction-to-rule mapping briefly, the source files changed, and validation performed. Report any correction left unresolved and why. Installed copies refresh on the next Home Manager activation.
