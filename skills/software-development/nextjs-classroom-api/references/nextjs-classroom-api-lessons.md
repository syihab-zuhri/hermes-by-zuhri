# Validated implementation notes

## P0 vertical slice

The validated slice implemented a Next.js 16 App Router classroom foundation with:

- `ClassroomSessionStore`: temporary session lifecycle, participant join, expiry cleanup, and 60-second host-disconnect grace period.
- `security.ts`: SHA-256 token hashing, timing-safe host/participant checks, and bounded rate limiting.
- `ClassroomApi`: create, join, authorized snapshot, and host lifecycle operations.
- Thin handlers:
  - `POST /api/v1/class-sessions`
  - `POST /api/v1/class-sessions/{id}/join`
  - `GET /api/v1/class-sessions/{id}?role=host|participant`
  - `POST /api/v1/class-sessions/{id}/lifecycle`

## Important corrections

- Map external snake_case payloads (`class_code`, `host_token`, `join_token`) to internal camelCase store options. Do not pass API input objects directly to domain methods.
- Do not return `host_token_hash` or `join_token_hash` from public responses. Tests should assert those properties are absent.
- Participant lookup must use the hash of the presented token, then verify the participant belongs to the requested session. Looking up a raw token as if it were a participant ID is incorrect.
- A snapshot route that requires authorization should return 403 before exposing whether an unknown session exists when no credentials are supplied.
- Direct Node tests require explicit `.ts` extensions for relative imports in route files; Next.js build also verifies the route graph.
- Ensure the npm test script includes both simulator and classroom globs; testing only the original simulator glob silently omits classroom tests.

## Verification gate

Validated commands for this slice:

```text
npm test                 # 55 passing tests (simulator, classroom, coursework, realtime, quality smoke)
npm run lint
npx tsc --noEmit
npm run build            # route graph includes all classroom, coursework, realtime, and health routes
git diff --check
```

## Coursework & E2E join-to-review slice (P0-013)

- `CourseworkStore`: isolates exercises, participant workspaces, deduplicated submissions, automatic evaluation, and teacher result/preview projections without polluting `ClassroomSessionStore`.
- Deeply nested route handlers (e.g. `[id]/exercises/[eid]/start/route.ts`) have varying relative depths (7 to 8 levels of `..`) to reach `lib/`. Count directory segments carefully to avoid `ERR_MODULE_NOT_FOUND` in direct Node test runners.
- Node strip-only mode (`--experimental-strip-types`) forbids parameter property constructors across all stores; declare explicit class fields and initialize in constructor body.
- In Next.js App Router client components, avoid inline `Math.random()` or `Date.now()` inside component render scope to satisfy strict `react-hooks/purity` lint rules. Use `crypto.randomUUID()` in top-level utility functions.
- E2E flow tests directly asserting the sequence (teacher create -> create exercise -> start exercise -> student join -> get active exercise -> submit workspace -> teacher results review -> teacher preview) provide verifiable task completion evidence before marking UI/flow tasks done.

## Realtime sequence & ticket-gated SSE slice (P0-014)

- `RealtimeHub`: assigns monotonic per-session sequences (`sequence += 1`) and maintains a 64-event circular buffer for instant replay on client reconnect. Emits gap detection (`reconciled: "snapshot"`) when a client fell behind the buffer.
- `RealtimeProtocol`: transport-agnostic command handling for `subscribe`, `unsubscribe`, `heartbeat`, `reconcile`, `lifecycle_change`, and `workspace_changed`. Decouples event generation from transport layer.
- `TicketStore`: solves browser `EventSource` / `WebSocket` header limitation without URL secret leakage. Clients exchange Bearer tokens via `POST /api/v1/realtime/tickets` for a single-use opaque ticket UUID with 10s TTL, which is immediately consumed on `GET /api/v1/realtime?ticket=...`. Reusing a consumed ticket returns 403.
- Stream route cleanup: call `heartbeat.unref?.()` on recurring interval timers and listen to `request.signal.addEventListener('abort')` to close readers and clear timers; otherwise Node test runners and dev processes hang waiting for open timer handles to exit.
- Stream reader lock in test assertions: call `reader.releaseLock()` or cancel the reader in test assertions so subsequent reads on the same response stream do not throw `TypeError [ERR_INVALID_STATE]: ReadableStream is locked`.

## Deployment, health, rollback, and synthetic pilot slice (P0-017/P0-018)

- Dynamic health routes: `/health/live` and `/health/ready` require `export const dynamic = "force-dynamic"`. Without this, Next.js statically caches the build-time response and runtime liveness/readiness reports become static fiction.
- Next.js Turbopack Edge warning in `instrumentation.ts`: checking `process.pid` unconditionally flags a build warning. Always guard with `process.env.NEXT_RUNTIME === "nodejs" ? process.pid : undefined`.
- Standalone output configuration: set `output: "standalone"` in `next.config.ts`. In Docker, copy both `.next/standalone` to `/app` and `.next/static` to `/app/.next/static`, and ensure the container runs under a dedicated non-root user (`USER app`).
- Rollback drill performance on WSL: recursive deletion or copying of `.next/standalone` (thousands of small files) across Windows-mounted filesystems (`/mnt/d/`) takes 30-40 seconds and causes command timeouts. In drill harnesses, test rollback by backing up the entrypoint (`server.js`) or using atomic directory symlinks.
- Process cleanup in test harnesses: Next.js standalone runner forks internal worker processes (`next-server`). When running drill scripts, ensure the port is truly released between stages by probing the port until it refuses connection (`ensurePortFree()`), and kill the child process cleanly.
- Synthetic pilot verification: run an automated driver script (`scripts/pilot.mjs`) against the production standalone server (`node .next/standalone/server.js`) on a clean port. Verify every item in the Definition of MVP Success:
  - Anonymous join with class code and nickname.
  - Multi-participant presence over live SSE.
  - Exercise creation, distribution, and auto-evaluation with distinct score outcomes (100 for correct, 1-99 for partial, 0 for empty, 400 for malformed).
  - Network disconnect simulation and event sequence replay: client disconnects, a late student joins, client reconnects with `last_sequence`, server replays the missed event, followed by a synchronized full snapshot.
  - Verification of access boundaries (students forbidden from teacher review).
- Git push workflow scope: GitHub rejects pushes modifying `.github/workflows/` if the OAuth/personal access token lacks the `workflow` scope. Store CI templates in `ci/workflow.yml` or document the requirement so automated pipelines don't fail at push time.

## Client-side and offline-first classroom adaptations (SPAs / Desktop)

- **Zero-backend BroadcastChannel Hub**: When porting classroom sessions to client-only SPAs (Vite, Tauri) without a live backend server, coordinate multi-tab communication across tabs on the same origin via `BroadcastChannel('openpacket_classroom_bus')`. This allows teachers and students to interact locally in separate browser windows.
- **Node/Vitest Storage Fallback**: In Node/Vitest test environments where `localStorage` is not globally provided, accessing `localStorage` directly causes `ReferenceError: localStorage is not defined`. Implement an `InMemoryStorage` fallback with a safe `getStorage()` selector that falls back gracefully when `window.localStorage` is unavailable.
- **Automated Exercise Evaluator**: Connect the simulator engine (`HeadlessSimulationEngine`) directly to an exercise evaluator that checks target criteria deterministically: IP port configurations, physical link connectivity, device type counts, switch VLAN modes (`access` vs `trunk`), and executes real ICMP ping simulations to calculate scores (0–100) with detailed passed/failed checklist feedback.
- **Lightweight Relay DoS & Token Authorization Guard**: When pairing client SPAs with a lightweight Node HTTP/Vite dev-middleware event relay (`scripts/classroom-relay.mjs` and `vite.config.ts`), raw request stream parsers (`req.on('data')`) must enforce an explicit payload limit (e.g. 1 MB, HTTP 413) to prevent heap exhaustion. Teacher lifecycle mutations (`CLASS_CLOSED`, `EXERCISES_UPDATED`, `EXERCISE_STARTED`, `CLASS_STATUS_CHANGED`, `CLASS_SETTINGS_CHANGED`) and room creation must strictly validate `hostToken` against the room's session token to prevent unauthorized room closure or tampering by connected students.
- **Centralized Client Auto-Sync**: Consolidate client polling timers into a single reference-counted watcher in the classroom hub (`startAutoSync()`). Avoid having multiple UI components (e.g., full modal and student HUD) independently poll the server every 2 seconds with heavy `JSON.stringify` comparisons, which causes thread stutter and redundant traffic.
- **Room TTL Eviction in In-Memory Relays**: Unbounded in-memory `Map` stores for relay rooms leak memory on long-running development servers. Implement automatic garbage collection on incoming requests or periodic timers: evict rooms inactive for > 24 hours or closed for > 2 hours.

The in-memory singleton runtime is acceptable for a P0/MVP route proof only. Before production, replace it with a shared durable store and define WebSocket/reconnect semantics in the ADR.
