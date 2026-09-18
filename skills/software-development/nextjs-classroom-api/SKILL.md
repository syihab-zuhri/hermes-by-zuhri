---
name: nextjs-classroom-api
description: "Use when building Next.js classroom session APIs."
version: 0.1.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [nextjs, classroom, api, sessions, authorization, testing]
---

# Next.js Classroom API

Use this skill for temporary classroom/session APIs in Next.js App Router projects: create class, participant join, authorized snapshots, lifecycle controls, expiry, and the transition from an in-memory MVP to durable storage/realtime transport.

## Core workflow

1. Read the project API, ERD, security, and ADR documents before choosing route shapes or storage.
2. Build a framework-agnostic service around a session store first. Keep domain operations testable without starting Next.js.
3. Write a failing service test for one vertical behavior, verify RED, implement the smallest behavior, verify GREEN, then proceed to the next slice.
4. Add thin App Router handlers that only parse input, extract authorization, call the service, and map results to HTTP responses.
5. Test handlers directly with Web `Request`/`Response`; this catches route parsing and status-envelope errors without requiring a server.
6. Never expose plaintext tokens or token hashes in public success projections. Store only hashes and compare authorization using timing-safe equality.
7. Use one canonical error envelope for all failures: `{ ok: false, error: { code, message, details, request_id } }`. Map validation, forbidden, missing, conflict, and rate-limit errors to 400, 403, 404, 409, and 429.
8. Update task and traceability documents only after tests prove the behavior. Keep UI/E2E/WebSocket work marked incomplete when only the API foundation exists.
9. Run the full test script, lint, typecheck, production build, and `git diff --check` before committing.

## Recommended separation

- `lib/classroom/session.ts`: session/participant lifecycle, expiry, host grace period, cleanup, hashed credentials.
- `lib/classroom/coursework.ts`: exercise management, participant workspace snapshots, deduplicated submissions, automatic evaluation, and teacher result/preview projections.
- `lib/classroom/security.ts`: token hashing, timing-safe authorization, rate limiter.
- `lib/classroom/realtime/hub.ts`: monotonic event sequencing, circular event buffer, gap detection, in-process publish/subscribe.
- `lib/classroom/realtime/protocol.ts`: transport-agnostic command handling (`subscribe`, `heartbeat`, `reconcile`, `workspace_changed`, `lifecycle_change`), authorization, snapshot/replay.
- `lib/classroom/tickets.ts`: short-lived, single-use ticket exchange store for secure SSE/WebSocket authentication without leaking bearer tokens in URLs.
- `lib/classroom/api.ts`: public service methods and canonical result envelope.
- `lib/classroom/http.ts`: process runtime, bearer parsing, JSON body parsing, HTTP result mapping.
- `app/api/v1/.../route.ts`: thin Next.js adapters (REST routes and SSE stream `/api/v1/realtime` + ticket endpoint).
- `app/classroom/page.tsx`: teacher control, live student monitoring/review, and student exercise submission UI.
- `lib/classroom/*.test.ts`: service, direct route, and E2E join-to-review integration tests.

## Security rules

- Hash host and participant credentials at creation; do not return hashes from create/join responses.
- Bind participant authorization to both the token hash and the target session ID.
- Require authorization before returning a session snapshot or student results. Missing credentials are forbidden, not a not-found signal.
- In Next.js client components, avoid inline impure calls (`Math.random()`, `Date.now()`) in render scope to satisfy `react-hooks/purity`; use top-level helper functions with `crypto.randomUUID()`.
- Unbounded body DoS protection: stream body parsers in classroom relay/middleware must enforce a strict `MAX_BODY_BYTES` limit (e.g. 1 MB) and destroy the stream with HTTP 413 to prevent memory exhaustion.
- Host-exclusive event authorization: Room management operations (closing sessions, modifying question banks, toggling participant policies) must check the session `host_token` and reject mismatched callers with `403 FORBIDDEN` to prevent room hijacking.
- Active room collision prevention: When a class creation request specifies an existing room code, reject takeover with `403 FORBIDDEN` if an active non-closed session exists under a different `host_token`.
- Stale room eviction (TTL GC): In-memory room maps must run periodic cleanup (`cleanupStaleRooms`) to prune inactive rooms (e.g. >24h) and closed rooms (e.g. >2h) using `.unref()` timers to prevent memory leaks without blocking process shutdown.
- Shared relay core: Keep relay protocol middleware in a shared pure handler module (e.g. `classroom-relay-core.mjs` / `.ts`) imported by both standalone runners and bundler dev-server plugins to guarantee consistent validation and prevent logic drift.
- Realtime auth without leaking secrets: browser `EventSource` and native `WebSocket` cannot pass custom headers. Do not put long-lived tokens in query parameters. Use an authenticated ticket-exchange pattern: client issues an authenticated `POST /api/v1/realtime/tickets` with Bearer header, receives an opaque single-use ticket with short TTL (e.g. 10s), and the stream endpoint immediately consumes and deletes it on connection.
- Treat the in-memory process store as MVP-only. It is not suitable for multi-instance production because sessions disappear on restart and are not shared across workers.
- Keep rate limiting explicit and injectable so deployment-specific limits can replace the MVP limiter.

## Route design

- Session: `POST /api/v1/class-sessions` (create), `POST /api/v1/class-sessions/{id}/join` (join), `GET /api/v1/class-sessions/{id}` (snapshot), `POST /api/v1/class-sessions/{id}/lifecycle` (lifecycle).
- Coursework: `POST /api/v1/class-sessions/{id}/exercises` (create exercise), `POST /api/v1/class-sessions/{id}/exercises/{eid}/start` (start exercise), `GET /api/v1/class-sessions/{id}/exercises/active` (active exercise).
- Submissions & Review: `POST /api/v1/class-sessions/{id}/submit` (student submit), `GET /api/v1/class-sessions/{id}/results` (teacher review), `GET /api/v1/class-sessions/{id}/results/preview` (workspace preview).
- Realtime: `POST /api/v1/realtime/tickets` (single-use ticket exchange), `GET /api/v1/realtime?ticket=...&last_sequence=...` (SSE stream with snapshot & event replay).
- Route params use `Promise<{ id: string }>` for current Next.js App Router async handler signatures. Count relative path depths accurately (up to 8 `..` levels) in nested route folders for direct Node test runner execution.

## Validated implementation lessons

- Keep the service HTTP-agnostic and put runtime concerns in a small adapter. In this project, `http.ts` owns the process-local singleton, JSON parsing, Bearer extraction, and result-to-`Response` mapping; route files remain thin.
- Test App Router handlers with direct `Request` objects and the actual async `context.params` shape. This catches relative-import and route-contract mistakes before a server smoke test.
- Authorization order is part of the contract: a snapshot request without a Bearer token returns `403 FORBIDDEN` before session lookup, so tests must distinguish authentication failure from a valid authenticated `404` lookup.
- Public projections must be checked negatively, not only positively: assert that `host_token`, `host_token_hash`, and `join_token_hash` are absent from create, join, and snapshot responses.
- When Node's strip-only TypeScript execution is used for focused tests, avoid parameter-property constructors and keep explicit class fields; run `npx tsc --noEmit` as the project-level typecheck.
- Stream route timer cleanup: call `heartbeat.unref?.()` on recurring interval timers in SSE/long-lived route handlers, and handle `request.signal.addEventListener('abort')` to clear intervals and unsubscribe listeners. Otherwise Node test runners and dev processes hang waiting for open timer handles to exit.
- Stream reader lock in test assertions: call `reader.releaseLock()` or cancel the reader in test assertions so subsequent reads on the same response stream do not throw `TypeError [ERR_INVALID_STATE]: ReadableStream is locked`.
- Map external snake_case request fields (`class_code`, `join_token`) to internal camelCase store methods at the service boundary rather than leaking transport naming into the domain.
- Keep task evidence honest: mark the API foundation as partial when classroom UI, E2E, persistence, or WebSocket behavior is still pending.

## Test discipline

A passing full suite is not enough if the new tests never failed first. For each new endpoint or behavior, record the RED reason, then implement and rerun the focused test. Include malformed JSON/input, missing credentials, wrong credentials, session-not-found, expiry/closed-session mutation, credential redaction, and success projections.

## Quality gates and smoke evidence (P0-015/P0-016 class)

- Prototype-pollution guards must be tested with RAW JSON strings, not `JSON.stringify`. `JSON.stringify({__proto__: {...}})` silently drops the `__proto__` key, so a fixture built with stringify never reaches the guard and the test gives false confidence. Write payloads as literal strings: `'{"schema":...,"__proto__":{"admin":true}}'`. Guard server-side by rejecting `"__proto__"|"constructor"|"prototype"` keys in the raw input BEFORE `JSON.parse`.
- Accessibility/contrast smoke must parse the LIVE token values from the shipped stylesheet, not hex codes copied from design docs. Docs drift: this session found `DESIGN.md` listed a muted token (`#718096`, 4.02:1 — fails AA) while `app/globals.css` shipped `#4a5568` (7.24:1). In Node tests read the file via `new URL("../../app/globals.css", import.meta.url)` + `readFileSync`, regex-extract `--token: #hexdef`, then compute WCAG relative-luminance ratios in-test. A hardcoded-hex contrast test asserts nothing about what actually ships.
- Record visual smoke as a LIVE HTTP verification, not just prose: start `npm run dev -- -p <port>` in background, poll until `curl` returns 200, assert expected markup strings appear in the fetched HTML, and probe an API route (a `405` on GET proves a POST-only route is mounted). Plain `npm run dev` may bind a different port than assumed — always pass `-p` explicitly and read the server log to confirm `Ready`. Kill the server after the check.
- Performance smoke budgets that proved stable for an in-memory MVP: ping + packet-frame projection on a 4-device topology < 15 ms; 50 concurrent joins via `Promise.all` < 200 ms followed by a snapshot integrity assert (`participants.length === 50`). Use `performance.now()` around the calls and assert with a message that prints the actual duration.
- Extend the same negative-projection discipline to smoke tests: assert the host secret string is absent from `JSON.stringify` of create responses AND from `exportWorkspace` output, and that participant tokens get `FORBIDDEN` on host-only operations (lifecycle change, teacher results).

## Deployment, health, rollback drills, and synthetic pilots (P0-017/P0-018 class)

- Health check routes: implement `/health/live` (process alive) and `/health/ready` (session store and realtime hub reachable). Always specify `export const dynamic = "force-dynamic"` on health check routes in App Router so Next.js does not statically pre-render them during build.
- Telemetry & structured logging: emit JSON lines via Next.js `instrumentation.ts` (`service.boot` and periodic `metrics.classroom`). To avoid Edge runtime compilation warnings in Turbopack/Webpack, guard Node-specific references: `pid: process.env.NEXT_RUNTIME === "nodejs" ? process.pid : undefined`. On recurring `setInterval` timers, call `timer.unref?.()` to avoid blocking graceful process exit.
- Standalone runner & Docker: configure `output: "standalone"` in `next.config.ts`. A multi-stage Dockerfile copies `.next/standalone` and `.next/static` to `./.next/static`, running as a non-root user with a built-in `HEALTHCHECK`.
- Rollback drill on mounted filesystems: do NOT recursively copy or delete the entire `.next/standalone` directory (10,000+ files) during automated rollback drills on WSL or mounted disks (`/mnt/...`) — filesystem I/O overhead causes command timeouts. Instead, test rollback by backing up the entrypoint `server.js` or switching release directory symlinks.
- Process tree termination: Next.js standalone forks a child worker process (`next-server`). When running drill harnesses, ensure the port is completely freed between stages by waiting for connections to fail (`ensurePortFree()`), and kill the process cleanly.
- Controlled synthetic pilot: test the running production standalone build over real HTTP and SSE with a driver script. Verify all Definition of MVP Success criteria: anonymous join, multi-student room, exercise distribution, evaluator score differentiation (passed/partial/failed/malformed), live SSE event stream, and network reconnect with event replay (`last_sequence`).
- GitHub workflow token scope: git pushes containing `.github/workflows/` require the `workflow` OAuth/token scope. If operating under standard repo-scoped tokens, store CI pipeline templates in `ci/workflow.yml` or document the workflow scope requirement to avoid rejected pushes.

See `references/nextjs-classroom-api-lessons.md` for validated implementation notes and failure patterns.
