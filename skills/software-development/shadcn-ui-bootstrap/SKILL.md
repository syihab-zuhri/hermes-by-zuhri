---
name: shadcn-ui-bootstrap
description: Bootstrap shadcn/ui projects on WSL with npm + Next.js 16.
version: 0.1.0
author: Zuhri (zuhri), Hermes Agent
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [shadcn, nextjs, bootstrap, wsl, npm]
    related_skills: [shadcn-ui-patterns, linux-runtime-provisioning]
---

# shadcn/ui Bootstrap (WSL)

Bootstrap a new shadcn/ui project under `/root/` on this WSL host using npm + Next.js 16. Use when the user says "init shadcn", "new shadcn project", "create a Next.js app with shadcn", or asks to scaffold a UI project. Don't use for: editing existing shadcn code (load `shadcn-ui-patterns` instead), non-Next frameworks without confirmation, or production deployment.

## When to Use

- User wants a fresh shadcn/ui (Base UI or Radix) project.
- User wants to add a registry, switch presets, or change base (radix ↔ base) on an existing project.
- User asks "what components do I have" or "refresh project context".

## Don't Use For

- Writing shadcn components/forms/chat UI → load `shadcn-ui-patterns`.
- Deploying or hosting the app.
- Editing files outside `components/`, `app/`, `lib/`, `components.json`.

## Prerequisites

- WSL Linux, Node 18+ (check: `terminal(command="node -v")`).
- npm available (`terminal(command="npm -v")`). User prefers npm for this skill even though other projects use pnpm.
- Working internet — shadcn CLI fetches templates from `ui.shadcn.com` and installs from npm.
- No project name conflict at target path.

## Project Conventions (this profile)

- **Projects live under `/root/`** (e.g. `/root/shadcn-app`, `/root/posyandu-app`).
- **Package manager**: npm (user-confirmed 2026-09-03; do not auto-promote pnpm even though `linux-runtime-provisioning` defaults to it).
- **Template default**: `next` (Next.js App Router).
- **Preset default**: `nova` (Base UI, current upstream default). Other named presets: `vega`, `maia`, `lyra`, `mira`, `luma`, `sera`, `rhea`.
- **Base default**: `base`. Switch to `radix` only on user request.
- **Monorepo**: off by default; ask before enabling.
- **RSC**: on (Next.js App Router default).
- **Icons**: `lucide` (preset default).
- **Font**: `geist` (preset default).

## Quick Reference

```bash
# Refresh project context in cwd.
npx shadcn@latest info --json

# Initialize new project under /root.
cd /root && npx shadcn@latest init \
  --name <name> \
  --preset nova \
  --template next \
  --base base \
  -y

# Add components (always read docs first per shadcn-ui-patterns).
npx shadcn@latest docs <component1> <component2>   # get URLs
npx shadcn@latest add <component>                  # install

# Preview before adding/updating.
npx shadcn@latest add <component> --dry-run
npx shadcn@latest add <component> --diff <file>

# Preset operations.
npx shadcn@latest preset resolve              # inspect current project preset
npx shadcn@latest preset decode <code>        # inspect a preset code
npx shadcn@latest apply <code>                # overwrite theme/font/components
npx shadcn@latest apply <code> --only theme   # theme only
npx shadcn@latest apply <code> --only theme,font

# Search/view before installing.
npx shadcn@latest search @shadcn -q "sidebar"
npx shadcn@latest view @shadcn/button
```

Note: there is **no `--package-manager` flag** on the `init` command — npm is selected by being in the cwd's detected runner. If the user later switches to pnpm, substitute `pnpm dlx shadcn@latest` and `bunx --bun shadcn@latest` per upstream SKILL.md.

## Procedure

1. **Confirm intent + scope** before running `init`. Ask the user for: project name (directory under `/root`), template (`next` default), preset (`nova` default), and whether it's a fresh dir or an existing one (forces `--force`).
2. **Check the target path.** `terminal(command="ls /root/<name> 2>&1")` — abort if non-empty without `--force`.
3. **Run `init`.** Use the exact flag shape from Quick Reference. Capture stdout — it logs "Created N files" and the components added. Note: `--preset` takes a **name** (`nova`), not `base-nova` — `base-nova` is rejected (verified 2026-09-03). The `--base base` is implied but pass it explicitly to avoid ambiguity when switching to `radix`.
4. **Verify `components.json` exists and parse it.** It must contain `style`, `rsc`, `tailwind.css`, `aliases`, `iconLibrary`. Print `aliases.components` so subsequent `add` commands resolve `@/components` correctly.
5. **Verify scaffold with `info --json`.** Confirm `framework: next`, `base: base` (or radix), `tailwindVersion: v4` (CSS-only, no `tailwind.config.js`), `rsc: true`, and `components` array lists what `init` claimed to install.
6. **Smoke-test the dev server.** Run via background terminal on a free port (default collision risk on 3000 — pick `3344` or higher):
   - `terminal(background=true, command="cd /root/<name> && PORT=<port> npm run dev")`
   - Wait ~10s, then `terminal(command="curl -sS -o /tmp/home.html -w 'HTTP %{http_code}\\n' http://127.0.0.1:<port>/")`.
   - Expected: HTTP 200, body contains markup for the default page (look for `Button` if the starter rendered one).
   - Kill via `process(action="kill", session_id=...)`.
7. **Report** the created files, components installed, alias map, and dev-server verification result. Hand off to `shadcn-ui-patterns` if the user wants to add components or write pages next.

## Updating / Switching Presets on an Existing Project

Before applying a new preset to an existing project, **always ask** which mode: `overwrite`, `partial` (`--only theme,font`), `merge` (`init --preset <code> --force --no-reinstall` then per-component `--dry-run --diff` + smart-merge), or `skip` (`init --preset <code> --force --no-reinstall`). Never default. Always run inside the project directory.

## Pitfalls

- **`--preset base-nova` is invalid** — the CLI accepts only the name (`nova`, `vega`, ...). The preset's internal style id is `base-nova`, but the flag takes the short name (verified 2026-09-03: returned `Invalid preset: base-nova. Available presets: nova, vega, maia, lyra, mira, luma, sera, rhea`).
- **No `--package-manager` flag.** Init picks up the runner from cwd. Don't invent a flag — the upstream SKILL.md says substitute at invocation time, not via init flag.
- **`apply` requires a project with `components.json`.** A scratch dir without one will error. Use `init` first or `cd` into the target.
- **Preset codes don't encode `base`.** When working in a scratch dir for `--dry-run` comparisons, pass `--base <current-base>` explicitly so the diff matches the project's base.
- **Tirith scan warnings.** `npx shadcn@latest` triggers a `[MEDIUM]` threat-intel warning (ecosyste.ms lookup timeout) on every call. This is incomplete verification, not malicious — auto-approved by smart approval. Do not retry or block on it.
- **Next.js 16 is newer than training data.** Project AGENTS.md says read `node_modules/next/dist/docs/` before editing. Bootstrap alone doesn't need it, but any code added afterwards does.
- **Loader cache.** `skill_view` / `skills_list` won't show skills created in this session until a new session starts. Tell the user so they don't think the create failed.

## Verification

- `ls /root/<name>` shows `app/`, `components/`, `lib/`, `hooks/`, `public/`, `components.json`, `package.json`, `next.config.ts`, `tsconfig.json`, `node_modules/`.
- `cat /root/<name>/components.json` parses; aliases use `@/`.
- `npx shadcn@latest info --json` reports `framework: next`, `base: base`, `rsc: true`, `tailwindVersion: v4`, `components` array non-empty.
- `npm run dev` boots in < 1s on WSL; `curl http://127.0.0.1:<port>/` returns HTTP 200; HTML contains expected starter markup.