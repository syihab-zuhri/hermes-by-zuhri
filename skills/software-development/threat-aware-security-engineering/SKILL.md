---
name: threat-aware-security-engineering
description: "Defensive triage, supply-chain audit, and malware forensics."
version: 1.0.0
author: Zuhri (zuhri), Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [security, malware-analysis, supply-chain, forensics, dfir, threat-modeling]
    related_skills: [agentic-coding-discipline, ast-grep-code-surgery, requesting-code-review]
---

# Threat-Aware Security Engineering & Defensive Analysis

Methodologies for defensive malware triage, supply-chain vulnerability inspection, runtime forensics, and system persistence auditing. Adapted from the industry-standard `awesome-malware-analysis` corpus.

## When to Use

- Inspecting third-party scripts, packages, or webhooks before running or deploying.
- Investigating anomalous system behavior, mysterious port binds, or unexplained crashes.
- Auditing supply chain dependencies (npm, PyPI, Go modules) for obfuscated backdoors.
- Verifying server persistence cleanliness (cron, systemd, profile scripts, LD_PRELOAD).
- Don't use for: creating functional malware, exploits, or payload weapons.

## Defensive Triage Protocol

### 1. Static Triage & Deobfuscation
Before executing suspicious files or dependencies:
- Check entropy and string tables for embedded executables or encoded URLs.
- Identify common obfuscation patterns:
  - Base64/Hex decoders combined with `eval()` or `Function()`.
  - Byte array XOR loops and multi-layer string concatenation.
  - Dynamic `import()` or `require()` with variable path targets.
- Use `ast-grep` to identify suspicious AST constructs:
  ```bash
  ast-grep run -p 'eval($$$ARG)' --lang js
  ast-grep run -p 'exec($$$ARG)' --lang python
  ast-grep run -p '__import__("os").system($$$ARG)' --lang python
  ```

### 2. Supply-Chain Package Verification
When evaluating npm/PyPI dependencies:
- Inspect install hooks (`preinstall`, `postinstall` in `package.json`, `setup.py` / `build.rs`).
- Verify outbound network calls or child process spawning during build steps.
- Search for known IOCs (Indicators of Compromise) and verify cryptographic checksums.

### 3. Persistence & Host Integrity Auditing
Audit core persistence locations in Linux/WSL:
- **Cron**: `/etc/cron*`, `/var/spool/cron/crontabs/*`
- **Systemd**: `/etc/systemd/system/`, `/lib/systemd/system/`
- **Shell Startup**: `~/.bashrc`, `~/.profile`, `/etc/profile.d/*`
- **Dynamic Linker**: `/etc/ld.so.preload`, `LD_PRELOAD` environment variable

Quick persistence check command:
```bash
# Check scheduled tasks & hooks
crontab -l 2>/dev/null || true
ls -la /etc/cron.d/ /etc/cron.daily/ 2>/dev/null || true
cat /etc/ld.so.preload 2>/dev/null || true
```

### 4. Runtime & Network Forensic Inspection
- Verify open sockets and bound processes:
  ```bash
  ss -tulpn
  ```
- Identify unexpected outbound connections or high-frequency DNS requests.
- Inspect process trees for masquerading processes or living-off-the-land executions (e.g. `curl` piping into `bash`).

## Verification
- Statically extract symbols or strings using `ast-grep` or `read_file`.
- Reconcile process IDs with real binary paths on disk (`/proc/<pid>/exe`).
- Ensure all defensive conclusions are grounded in immutable evidence.
