---
name: ast-grep-code-surgery
description: "Perform structural AST code search, outline, and rewrites."
version: 1.0.0
author: Zuhri (zuhri), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [ast-grep, tree-sitter, structural-search, codemod, refactor, code-intelligence]
    related_skills: [agentic-coding-discipline, systematic-debugging, codebase-inspection]
---

# ast-grep Code Surgery & Structural Intelligence

Performs structural Abstract Syntax Tree (AST) search, codebase outlining, and semantic code rewriting using `ast-grep` (Rust + Tree-sitter).

Unlike text-based grep or line diffs, AST matching is immune to whitespace changes, formatting drift, multi-line arguments, and comment placement.

## When to Use

- Inspecting a project's architecture rapidly without token bloat (`ast-grep outline`).
- Finding complex structural patterns (e.g. all async functions lacking try/catch, unguarded database queries, unmemoized hooks).
- Multi-file semantic refactoring / codemods where symbol signatures or import styles change.
- Patching code where traditional regex or string replace fails due to formatting discrepancies.

## Core Commands

### 1. Codebase Outline (90% Token Reduction)
Extract functions, classes, interfaces, and exported symbols:
```bash
# Outline a single file or directory
ast-grep outline src/

# Filter outline via JSON output
ast-grep outline --json src/
```

### 2. Structural Search (`ast-grep run -p`)
Use `$NAME` for single identifiers, `$$$ARGS` for multiple statements/arguments:

```bash
# Find all console.log calls regardless of whitespace or argument count
ast-grep run -p 'console.log($$$ARGS)' --lang ts

# Find all fetch calls in TypeScript/JavaScript
ast-grep run -p 'await fetch($$$URL_AND_OPTIONS)' --lang ts

# Find React useState hooks
ast-grep run -p 'const [$VAL, $SET] = useState($INIT)' --lang tsx

# Find Python functions with specific decorators
ast-grep run -p '@app.get($PATH)\ndef $FUNC($$$PARAMS):\n  $$$BODY' --lang python
```

### 3. Structural Rewrite / Codemod (`ast-grep run -p ... -r ...`)
Safely replace code matching syntax trees:

```bash
# Rewrite legacy function call to new signature
ast-grep run -p 'oldApi($A, $B)' -r 'newApi({ first: $A, second: $B })' --update-all

# Rewrite imports across the repository
ast-grep run -p 'import { $X } from "old-lib"' -r 'import { $X } from "new-lib"' --update-all
```

## Advanced Rule Scanning (`ast-grep scan`)
For relational constraints (`has`, `inside`, `not`):
```yaml
id: unguarded-fetch
language: typescript
rule:
  pattern: fetch($$$ARGS)
  not:
    inside:
      kind: try_statement
      stopBy: end
```
Execute with:
```bash
ast-grep scan --inline-rules "<yaml>" path/to/code
```

## Verification
- Run `ast-grep --version` to confirm CLI presence.
- Test pattern match with `--json` or dry-run before applying `--update-all`.
