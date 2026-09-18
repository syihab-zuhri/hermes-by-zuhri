# WSL ↔ Windows MCP synchronization reference

## Transport mapping

For each source entry, preserve:

- `url`, `auth`, `oauth`, `timeout`, and `connect_timeout` for HTTP MCP servers.
- `tools.exclude` or other tool-selection filters.
- `command` and `args` for stdio servers only when the command exists on Windows.

A common cross-platform pattern is:

```yaml
mcp_servers:
  remote_service:
    url: https://example.invalid/mcp
    auth: oauth
    timeout: 180
  local_service:
    command: local-service.exe
    args: [stdio]
```

Do not point Windows Hermes at `/usr/local/bin/...` or a Linux ELF binary. Install the Windows executable and verify it from Windows:

```text
local-service.exe --version
```

If the target cannot resolve the command, use an absolute Windows path or add the containing directory to the Windows PATH, then restart Hermes.

## OAuth cache handling

Hermes stores MCP OAuth material below:

```text
<HERMES_HOME>/mcp-tokens/<server>.json
<HERMES_HOME>/mcp-tokens/<server>.client.json
<HERMES_HOME>/mcp-tokens/<server>.meta.json
```

These are sensitive. Copy only for the same user's local installations, preserve restrictive permissions, and never display file contents. Prefer target-side login when uncertain:

```text
hermes mcp login <server>
hermes mcp reauth --all
```

A successful connection test is the authority; presence of cache files is not.

## Verification checklist

Run on the target installation:

```text
hermes --version
hermes mcp list
hermes mcp test <server-1>
hermes mcp test <server-2>
```

Record for each test:

- transport (HTTP or stdio)
- endpoint/command, with secrets redacted
- authentication mode
- discovered tool count
- any re-authentication requirement

For a large set, test every configured server rather than sampling. Cloud or catalog servers may take several seconds to discover tools; a timeout should be investigated and retried only after checking connectivity and credentials.

## Target-runtime diagnosis

If the Windows launcher reports a Python-child or runtime-spawn error before `--version`:

1. Check the target Hermes installation's virtual environment metadata and whether its referenced interpreter exists.
2. Repair the embedded runtime through Hermes/uv's supported installation path, or point the environment at an existing compatible Windows Python only if the package's launcher supports that layout.
3. Confirm `hermes --version`.
4. Only then modify or test MCP configuration.

Do not use a WSL Python interpreter for Windows Hermes. Do not treat a launcher repair as evidence that MCP itself is broken.

## Backup and merge rules

Before editing the target config, create a timestamped backup. Merge only the source `mcp_servers` block; retain target model, profiles, gateway, platform, skills, and unrelated settings. After the edit, run the target's MCP listing command and tests. A YAML parse or `mcp list` result alone is insufficient evidence that every server works.