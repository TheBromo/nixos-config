---
name: create-github-pr
description: Create GitHub pull requests with conventional branch names, commits, and PR titles, plus an Overview and file-by-file Changes description. Use when asked to open a PR or prepare its title and body.
---

# Create GitHub PR

## Naming

Use the installed `conventional-branch` skill for branch names and `conventional-commits` skill for commits. Name branches `<type>/<short-description>` with lowercase, hyphen-separated descriptions (for example, `bugfix/handle-empty-response` or `feature/add-export`).

Use Conventional Commits syntax for the PR title as well: `<type>(<optional-scope>): <description>`. Omit the parentheses when there is no scope, and use `!` before the colon for a breaking change. Choose the type and scope from the overall change, not merely the latest commit. For example: `fix(api): handle empty responses`.

Apply these conventions to branches and commits created for this task. Do not rewrite published history solely to normalize old commit messages.

## PR description

Inspect the complete diff against the intended base branch, including all commits in the PR. Use exactly these two bold section labels, in this order:

```markdown
**Overview**
Concise description of what this PR fixes or adds and why.

**Changes**
- `path/to/file`: Short description of what changed in this file.
- `path/to/another-file`: Short description of what changed in this file.
```

Keep the overview to one short paragraph. Include one bullet for every changed file, including additions, deletions, generated files, and lockfiles. Describe a rename in one bullet with both paths. Explain the substantive change in each file; do not group files behind directory names or globs. Base every claim on the final diff. Do not add extra sections unless the user requests them.

## Publication

Determine the repository, head branch, and intended base before publishing. For a stacked branch, use the installed `gh-stack` skill and compare against the stack parent so the description covers only this PR's changes.

When asked to create a PR, commit the intended changes as needed, push the branch, and always create the PR as a draft using the prepared title and body. Use `gh pr create --draft` or the equivalent draft setting in the API or stack tool. A request only to draft a title or description does not authorize publication.

Pass multiline Markdown through a body file (`gh pr create --body-file`) or a structured API argument so newlines and literal characters survive intact. Check for an existing PR for the head/base before creating one. If creation has an ambiguous result, query for the PR before retrying to avoid duplicates; stop and report any unresolved authentication or permission failure.

Verify the published title, body, base/head branches, and draft status, then return the PR URL. Report relevant validation and any limitations in the response without adding unrequested sections to the PR body.
