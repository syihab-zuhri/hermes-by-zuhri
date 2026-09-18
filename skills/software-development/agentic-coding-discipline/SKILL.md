---
name: agentic-coding-discipline
description: "Execute precise, zero-stub code edits with verification."
version: 0.1.0
author: Zuhri (zuhri), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [coding, editing, verification, zero-stub, patch-safety, ground-truth]
    related_skills: [systematic-debugging, requesting-code-review, test-driven-development]
---

# Agentic Coding Discipline

Autonomous coding agent execution protocol adapted from high-reliability agent architectures (oh-my-pi / OMP). Enforces snapshot integrity, zero-stub completeness, token economy, and contract-grounded verification.

## When to Use

- Writing, modifying, or refactoring code across any file in a project.
- User reports a runtime error, bug, or unexpected behavior.
- Multi-file code changes, API adjustments, or dependency migrations.
- Don't use for: pure architectural planning without file edits (use `software-project-planning`), or running pre-commit scans (use `requesting-code-review`).

## Core Invariants

### 1. User's Word is Absolute (Ground Truth)
- User-reported state (errors, stack traces, test failures, behavioral anomalies) is ground truth.
- NEVER waste tool calls or turns re-verifying or asking confirmation for what the user already stated. Proceed immediately to investigating the root cause and fixing the source.

### 2. Snapshot Integrity & Anti-Stale Edits
- Every edit must target code freshly read in the session.
- If a patch fails or file content changed on disk, NEVER re-submit the same diff. Immediately re-read the target file with `read_file` to capture fresh line anchors and context, then formulate a new patch.
- Anchors and context lines must be copied verbatim including exact whitespace and indentation.

### 3. Zero-Stub & Anti-Scaffolding Law
- NEVER deliver unfinished code: no placeholders, no fake fallbacks, no `// TODO: implement later`, no mock stubs pretending to be done.
- Implement the complete end-to-end logic across every affected file.

### 4. Clean Cutover
- When modifying a function signature, interface, or exported symbol, inspect every caller with `search_files`.
- Update all callsites in the same changeset. Remove dead code, obsolete imports, and deprecated shims.

### 5. Batched Tool Dispatch
- Never burn an assistant turn executing only `todo` or isolated state updates.
- Batch independent file reads, searches, and planning updates into a single response.

### 6. Contract-Based Smoke Verification
- After completing edits, run the actual target command or a focused smoke script to prove behavior.
- Never claim code works without real runtime tool output confirming success.

## Execution Modes (OMP Adaptations)

- **Advisor Mode**: For high-risk refactors or critical migrations, dispatch an independent subagent (`delegate_task`) with a secondary model to audit diffs and catch flaws before cutover.
- **Autonomous Loop Mode**: When fixing failing tests or running benchmarks, loop automatically (`diagnose -> edit -> verify`) bounded by iteration count/timeout until target exit code is 0.
- **Vibe Mode**: For direct coding and rapid fixes, skip ceremonial multi-step planning files; execute directly with tight batching and smoke verification.
- **Extended Context**: Maintain full 512K context capacity for large multi-file analysis by tuning compression thresholds.
- **Web Dashboard**: Access session management, token metrics, and live chat via `hermes dashboard`.

## References

- See `references/omp-harness-principles.md` for background on hash-anchored diffing, token efficiency, and OMP execution modes (Advisor, Autonomous Loop, Vibe, Extended Context, Collab, Dashboard).
