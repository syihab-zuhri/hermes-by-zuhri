---
name: hermes-mcp-cross-platform
description: "Use when synchronizing Hermes MCP across WSL and Windows."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, windows, wsl]
metadata:
  hermes:
    tags: [hermes, mcp, wsl, windows, oauth, cross-platform]
---

# Cross-platform Hermes MCP synchronization

Use this skill when the same user wants MCP servers from one Hermes installation available in another Hermes installation, especially WSL ↔ Windows. The goal is to reproduce the configuration and working transports on the target platform, not to share a live process.

## Core workflow

1. Identify both Hermes homes and the target platform. On Windows the default is `%LOCALAPPDATA%\\hermes`; on WSL/Linux it is `~/.hermes`, unless `HERMES_HOME` or a profile overrides it.
2. Read the source `config.yaml` and copy only the `mcp_servers` configuration into the target config. Preserve unrelated target settings and make a timestamped backup first. Prefer Hermes config commands where they can express the change; use a carefully merged YAML edit only when copying a complete MCP block is necessary.
3. Port each transport correctly:
   - HTTP/Streamable HTTP entries keep their URL, timeout, and tool filters.
   - stdio entries must use an executable available on the target OS. A Linux ELF binary cannot be used directly by Windows Hermes; install or download the native Windows build, then reference its executable name or absolute path.
   - Keep environment variables and credentials out of `config.yaml` unless the MCP server explicitly requires an environment-based secret.
4. Handle OAuth separately. OAuth cache files are Hermes-home-local and may be copied only between installations owned by the same user, over a protected local filesystem, with restrictive permissions. Never print token contents or paste them into chat. If token formats or client registrations are incompatible, re-authenticate on the target with `hermes mcp login` or `hermes mcp reauth` instead of forcing a transfer.
5. Validate before declaring completion:
   - `hermes --version` on the target.
   - `hermes mcp list` shows every expected server.
   - `hermes mcp test <name>` succeeds for every server, reporting transport and discovered tool count.
   - For stdio servers, verify the target-native executable itself with `--version` or equivalent.
6. Report exactly what was copied, what was tested, any servers requiring target-side re-authentication, and the backup path. Do not claim tools are available merely because YAML parses.

## Runtime repair pitfall

If a packaged Hermes launcher fails before showing its version, inspect the target runtime rather than changing MCP configuration. A broken or missing embedded Python runtime can make the launcher fail even when the Hermes installation and config are present. Repair using the package's supported runtime mechanism or a valid same-version interpreter, then re-run `hermes --version` before MCP tests. Do not replace a target environment with a Linux interpreter or silently mix incompatible Python versions.

## Security boundaries

Treat MCP configs, OAuth caches, and environment files as secret-bearing. Do not expose token values in command output. Do not copy the entire Hermes home or overwrite the target config wholesale: that can replace sessions, profiles, model settings, and platform credentials. Keep a backup and preserve the target's non-MCP settings.

## Supporting detail

See `references/wsl-windows-mcp-sync.md` for the validated transport mapping, target-runtime checks, and verification checklist.