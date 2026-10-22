---
name: edit-custom-skills
description: Edit repository-owned custom coding skills, even while working in another project. Use when asked to add a pattern, rule, example, or reference to a custom skill such as Python, or to create a new custom coding skill.
---

# Edit custom skills

## Find the source

The source repository is `/Users/manuel/Development/nixos-config`. On another machine, try `$HOME/Development/nixos-config`. Verify that the chosen checkout contains `modules/home-manager/skills/default.nix` exporting `flake.lib.agentSkills`. If neither checkout exists, ask for its location.

Skills live under `modules/home-manager/skills/local/<skill-name>/`. Edit this source even when the active working directory belongs to another project. Use absolute file paths and `git -C <repository>` or commands with an explicit working directory.

Installed copies under `~/.codex/skills`, `~/.claude/skills`, and the OpenCode configuration are deployment outputs. Editing those copies loses changes on the next Home Manager activation. Paths under `/nix/store` are immutable build outputs.

## Make the requested change

1. Read the source repository's applicable instructions and Git status, then the target skill and relevant supporting files. Preserve unrelated work in both the source repository and the active project. Match the requested skill by its directory and frontmatter; create a new skill only when requested.
2. Turn the requested pattern into a reusable rule with its applicability and meaningful constraints. Use the active project's code as context when needed, while keeping project-specific names, secrets, and incidental details out of reusable examples. Integrate with existing guidance and resolve duplication or contradictions within the requested scope.
3. Put supporting examples and references inside the target skill directory. Honor requested filenames, such as `python/example.py`. Link them from `SKILL.md` with relative paths and explain when to read them. Keep the rule in the skill and the detailed demonstration in the example. Make runnable examples self-contained where practical and state any required dependencies.
4. For a new skill, add `<skill-name>/SKILL.md` with matching lowercase, hyphenated `name` and a concise `description` that states when it applies. The package copies the entire `skills/` directory, including supporting files; adding a skill needs no Nix wiring.

For example, “add this pattern to the Python skill, add example.py, and mention it in the skill” means updating these source files:

```text
modules/home-manager/skills/local/python/SKILL.md
modules/home-manager/skills/local/python/example.py
```

Add a contextual link such as `See [example.py](example.py) when implementing <pattern>.` under the relevant rule.

## Validate and report

Check frontmatter, relative links, and the scoped diff. Validate changed examples with the target language's skill and applicable tooling; run examples only when their effects are appropriate. Report unavailable checks explicitly.

Run `git diff --check` from the source repository. For a packaging check, new files must be Git-tracked before flake evaluation: stage only the newly added skill files, preserving unrelated index entries, then build `flake.lib.customCodingSkills` with the host's pinned package set. Check that the output contains the changed skill and its supporting files. Source-only edits do not require a full Home Manager build.

Report the source paths changed, validation performed, and that installed copies refresh on the next Home Manager activation. Commit, push, or activate only when requested; editing a skill alone does not request those actions.
