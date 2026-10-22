---
name: create-language-skill
description: Create a reusable language coding skill from the current codebase. Use when asked to derive language conventions, patterns, examples, or validation guidance from a project and package them as a custom coding skill.
---

# Create a language skill

Use the current codebase as evidence and the custom coding skills repository as the destination. Follow [edit-custom-skills](../edit-custom-skills/SKILL.md) for source discovery, editing, packaging, and validation, even when the current project is elsewhere.

## Discover the conventions

Identify the requested language. If unspecified, infer it from the active task and project manifests; ask when multiple languages are equally plausible and would produce different skills.

Read applicable repository instructions, manifests, formatter/linter/type-checker configuration, and representative implementation and test files. Follow a few real paths through public interfaces, domain logic, I/O, and failure handling where those exist. Look for maintained patterns across files rather than treating the first example as the standard.

Distinguish explicit standards and enforced checks from repeated conventions, one-off choices, and legacy inconsistencies. Prefer explicit guidance and maintained code when they disagree with older examples. Ask only when unresolved contradictions would materially change the proposed guidance.

## Write the skill

Inspect existing custom language skills before creating one. If the requested language already has a skill, integrate supported additions there while preserving its established guidance; explain that an existing skill was updated.

Write concise rules covering the evidenced decisions that matter, such as types and contracts, boundaries, errors, effects, dependencies, and testing. Each rule should tell a future agent when it applies and what to do. Separate transferable language guidance from framework-specific or project-specific choices, and state the scope of conditional rules. Avoid presenting local directory layouts, business names, or incidental implementation details as universal language conventions.

Keep the entrypoint focused on the working rules and validation workflow. Add supporting examples only when they clarify a non-obvious pattern or the user requests them; place them inside the skill and link them with conditions for reading. Adapt examples to remove secrets and project-specific data while preserving the behavior being taught.

Derive validation commands from actual project tooling. Express reusable commands with explicit path placeholders and conditions for lockfiles, dependencies, and tool availability. Carry over the relevant enforcement strength without assuming every future project has this project's toolchain. Verify any claim about configured checks against the configuration.

## Complete the change

Validate the skill and any new examples using the shared editing workflow. Review each rule against the inspected evidence; remove unsupported assumptions and duplicate advice. Report the destination, the source conventions captured, checks performed, and any unresolved limitations. Creating the skill does not request changes to the source project's code or tooling.
