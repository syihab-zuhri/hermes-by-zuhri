# OMP Harness Principles & Execution Modes (oh-my-pi Architecture Study)

Extracted from dissection of `can1357/oh-my-pi` (Rust + TypeScript monorepo) and adapted for Hermes Agent.

## 1. Hash-Anchored Edits (pi-edit)
- In OMP, file reads attach a 4-hex content hash tag `[file.py#A1B2]`.
- Edits (`PUT N.=M:`, `CUT N.=M`, `MV DEST`) must supply the matching `#TAG`.
- If the file has changed on disk or if line numbers drift, the tool rejects immediately, preventing silent code corruption and hallucinated line edits.
- **Hermes translation**: Always verify lines and context blocks with fresh `read_file` before calling `patch`. Never retry a failed patch with the identical diff string. Re-read on failure.

## 2. Token & Tool Round-Trip Economy
- OMP avoids single-tool micro-turns (e.g. updating a checklist alone).
- Tool calls that are logically independent (reading 3 related files, checking git status, searching symbol references) are batched concurrently.
- System prompts enforce terse, RFC 2119 directives (`MUST`, `NEVER`, `AVOID`) to minimize prompt bloat.

## 3. Real Debugger vs Print Statements
- OMP integrates DAP (lldb, dlv, debugpy) to inspect stack frames and variables directly.
- **Hermes translation**: Use `python-debugpy` or node inspect debugger rather than littering code with temporary print statements when diagnosing deep runtime failures.

## 4. OMP Execution Modes Adapted to Hermes

### Advisor Mode (`/advisor`)
- **OMP concept**: A secondary model (e.g. `opencode-zen/union-alpha:xhigh`) runs concurrently/passively to critique the primary model's changes, catch hallucinations, and warn of architectural regressions without halting the main flow.
- **Hermes workflow**:
  - Spawn an advisor subagent via `delegate_task` prior to executing high-risk refactors or database migrations.
  - Context for advisor: send the proposed diff / plan and ask for failure modes, security flaws, and contract violations.
  - Incorporate advisor critique into the final implementation before reporting completion.

### Autonomous Loop Mode (`/loop [--until '<cmd>'] [--while '<cmd>']`)
- **OMP concept**: Automatically re-submits the prompt after every yield until a test/command condition is satisfied (exit status 0).
- **Hermes workflow**:
  - Implement autonomous loops using `execute_code` or bounded `terminal` scripts.
  - Pattern:
    ```python
    # Iterative diagnose -> patch -> run command loop
    for iteration in range(max_attempts):
        res = terminal(command=test_cmd)
        if res["exit_code"] == 0:
            break
        # analyze error output and patch
    ```
  - Bounds: Always set a strict iteration cap (e.g. 5-10 iterations) and timeout.

### Vibe Mode (`/vibe`)
- **OMP concept**: Fast, persistent, unceremonious execution bypassing verbose multi-step planning gates for quick tasks and script iterations.
- **Hermes workflow**:
  - Pair with `/yolo` (approval bypass).
  - Skip boilerplate plan files (`PLAN.md`, `TODO.md`) when the task is a self-contained fix, single script, or exploratory experiment. Directly inspect, modify, test, and present the result.

### Extended Context (`extendedContext`)
- **OMP concept**: Unlocks full context windows (512K - 1M+ tokens) on supported providers instead of aggressive early compaction.
- **Hermes workflow**:
  - Model `combo-cepet-habis` on 9router supports 512K context.
  - Tune `compression.threshold` (e.g. 0.7 - 0.8) and `compression.protect_last_n` in `~/.hermes/config.yaml` to prevent early context pruning during large codebase reviews.

### Collab Mode (`/collab`)
- **OMP concept**: Live session sharing via relay / link for multi-user observation and prompting.
- **Hermes workflow**:
  - Leverage Hermes gateway (`hermes gateway`) across multiple connected channels (Telegram, Discord, Slack) and `hermes dashboard` web interface for multi-surface collaboration on the same profile.

### Skillful Mode (`/skillful`)
- **OMP concept**: Toggles whether the full skill catalog is injected into the prompt to preserve context tokens.
- **Hermes workflow**:
  - Hermes dynamically manages skills via `<available_skills>` catalog and loads full content on-demand with `skill_view`. Keep skill descriptions under 57 characters for efficient catalog injection.

### Usage Statistics Dashboard (`http://127.0.0.1:3847/`)
- **OMP concept**: Local web server on port 3847 rendering token metrics, costs, and session logs from `stats.db`.
- **Hermes equivalent**: Run `hermes dashboard` (default port 9119 or custom port) for full web GUI, live chat, session history, config management, and MCP status.
