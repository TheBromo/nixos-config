---
name: typescript
description: Write TypeScript in this style. Use when writing, refactoring, or reviewing TypeScript code.
---

# TypeScript

## Building objects

Build an object with optional fields as a typed local, then assign each
optional field in a plain `if`. The `if` names the condition and the field on
one line:

BAD

> ❌
> ```ts
> return {
>   ...node,
>   width,
>   height,
>   ...(node.children && { children: layoutChildren(node.children) }),
>   ...(node.ports && { ports: placePorts(node.ports, size) }),
> };
> ```

GOOD

> ✅
> ```ts
> const placed: Node = { ...node, width, height };
> if (node.children) placed.children = layoutChildren(node.children);
> if (node.ports) placed.ports = placePorts(node.ports, size);
> return placed;
> ```

Keep `{ ...source, key: value }` for copying an object with a few fields
replaced. That spread is the clear form.

When the input lacked a key, leave it absent rather than setting it to
`undefined`. If that distinction is why the `if` exists, say so in a short
comment.

Assign to locals, never to parameters or their properties. Follow the
repository's lint rules, such as `no-param-reassign`, instead of mutating
inputs.

## Module layout

When one file holds several distinct passes or concerns, such as placement and
routing in a layout engine, split it into a subfolder named after the module.

`index.ts` is the entry point. It holds the module's overview comment, shared
constants, and the public export that wires the parts together.

Give each concern its own file, named for what it holds. Export only what
sibling files or the entry point use, and keep helpers private. Put shared
types beside the code that builds them, and import them with `import type`.

Point importers and tests at the folder path and remove the old file. Move code
unchanged, so the split stays a pure reorganization.

## Functions

Keep nesting shallow. Lift a nested loop, closure or conditional into a small
named function with early returns, so the top-level function reads as a list
of steps.

Give a function a name only when the name says more than its body. A wrapper
that calls one function and returns a field is not worth a name; inline it at
its call sites:

BAD

> ❌
> ```ts
> function build(root: FillTask): Container {
>   depthFirstPreOrder(root, fill);
>   return root.target;
> }
>
> const copied = build({ source, target });
> ```

GOOD

> ✅
> ```ts
> const root: FillTask = { source, target };
> depthFirstPreOrder(root, fill);
> const copied = root.target;
> ```

## Traversals

Write no recursive functions. That covers direct self-calls, mutual recursion
and recursion through a callback or a returned closure. Walk trees and graphs
with a loop over an explicit stack or queue, and convert recursion you find in
code you are changing. Keep the visit order of the recursive version: a
stack-based pre-order pushes children in reverse so the leftmost comes out
first.

Call a traversal or search by its well-known name, in the function name and in
its comment: `depthFirstPreOrder`, `depthFirstPostOrder`, `breadthFirst`,
`topologicalOrder`, `dijkstra`, `aStar`. Rename vague names such as `walk`,
`visit`, `run` or `search` when you touch them.

Keep one copy of each traversal helper. When a module already has one under
another name, rename it there and update its callers instead of adding a
second helper beside it.
