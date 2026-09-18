---
name: omp-workflows
description: "Execute OMP workflows: vibe, loop, advisor, and extended."
version: 1.0.0
author: Zuhri (zuhri), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [omp, vibe, loop, advisor, extended-context, collab, skillful, workflows]
    related_skills: [agentic-coding-discipline, requesting-code-review, test-driven-development]
---

# OMP Workflows

Adaptation of core oh-my-pi (OMP) execution modes into Hermes Agent: Vibe mode, Autonomous Loop mode, Advisor mode, Extended Context, Collab, Skillful, and Web Dashboard.

## When to Use

- User requests `vibe` mode: bypass ceremonial planning for direct, high-speed coding.
- User requests `loop` mode: autonomous retry/fix cycles until a command/test passes (`--until '<cmd>'`).
- User requests `advisor` mode: secondary model critique to catch bugs and architectural flaws.
- Managing large codebases with `extended-context` (up to 512K context on 9router).
- Launching or monitoring web interfaces (Hermes Dashboard on port 9119, OMP Stats on port 3847).

## Execution Modes

### 1. Vibe Mode (`/vibe`)
- **Protocol**: Skip creating bulky `PLAN.md` or multi-level task checklists for small/medium tasks.
- Read files directly, formulate the fix, batch tool calls, execute patches, and run smoke tests immediately.
- Preserve zero-stub discipline: speed does not permit unfinished code or placeholders.

### 2. Autonomous Loop Mode (`/loop`)
- **Protocol**: Execute an automated cycle of `Diagnose -> Edit -> Verify` until target condition succeeds.
- Use `scripts/loop_runner.py` or an inline test loop bounded by max iterations (default 5-10).
- If `--until '<cmd>'` exits with code 0, declare success. If errors persist after max iterations, halt with clear diagnostics.

### 3. Advisor Mode (`/advisor`)
- **Protocol**: Prior to high-risk commits, schema migrations, or major refactors, dispatch an independent subagent via `delegate_task` with a reviewer model.
- Subagent evaluates diff against contract specifications, edge cases, and performance regressions.
- Integrate advisor findings before finalizing the response to the user.

### 4. Extended Context (`extendedContext`)
- **Protocol**: Maximize 512K context capacity for large multi-file analysis.
- Configuration applied in `~/.hermes/config.yaml`:
  - `compression.threshold`: 0.8 (compact only when 80% full)
  - `compression.protect_last_n`: 40 (retain 40 recent turns in context)

### 5. Collab & Multi-Surface
- Hermes operates across multiple surfaces simultaneously: CLI, Web Dashboard (`http://localhost:9119`), and messaging platforms (Telegram, Discord, Slack).
- Sessions and states synchronize via `/root/.hermes/state.db`.

### 6. Skillful
- Hermes dynamically registers and searches skills via `<available_skills>` and loads on-demand with `skill_view`.

### 7. Web Dashboard & Usage Statistics
- Hermes Web Dashboard: `hermes dashboard --skip-build --no-open --port 9119` (UI at `http://localhost:9119`).
- OMP Stats Dashboard: `omp stats` (UI at `http://localhost:3847/`).

## Verification
- Verify running dashboard: `hermes dashboard --status` and `curl -s -I http://127.0.0.1:9119/`.
- Verify extended context settings: `hermes config get compression`.
