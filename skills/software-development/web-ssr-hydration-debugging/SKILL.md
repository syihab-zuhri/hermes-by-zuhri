---
name: web-ssr-hydration-debugging
description: "Use when debugging SSR hydration or browser state sync."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [nextjs, react, ssr, hydration, web, debugging]
    related_skills: [systematic-debugging, test-driven-development]
---

# Web SSR & Hydration Debugging

## Overview

In SSR/SSG environments (Next.js App Router, Remix, Nuxt), accessing browser-only globals during component initialization causes **hydration mismatches** or **false-negative initial state** (e.g. `navigator.onLine`, `localStorage`, `window.matchMedia`, `window.innerWidth`).

## Core Rules

1. **Never read non-deterministic browser APIs in initial `useState()`**:
   - `navigator.onLine` can evaluate to `undefined` or `false` on initial client execution before connection probes settle, or create mismatch with server markup.
   - Initial state must match the server default (e.g., assume `true` / online), then update inside `useEffect()`.

2. **Pattern: Browser-only State Synchronization via `useSyncExternalStore`**:
   - Calling `setState` synchronously within `useEffect` triggers React 19 / ESLint `react-hooks/set-state-in-effect` errors (cascading renders).
   - Use `useSyncExternalStore` for clean, tear-free, SSR-safe subscriptions to external browser events:

```tsx
// ❌ Anti-pattern: Hydration mismatch / early false triggers
const [isOnline, setIsOnline] = useState(
  typeof navigator !== "undefined" ? navigator.onLine : true
);

// ❌ Anti-pattern: Direct setState in effect body triggers linter errors
useEffect(() => {
  if (navigator.onLine === false) setIsOnline(false); // ESLint react-hooks/set-state-in-effect
}, []);

// ✅ Best practice (React 18/19): useSyncExternalStore
import { useSyncExternalStore } from "react";

function subscribe(callback: () => void): () => void {
  window.addEventListener("online", callback);
  window.addEventListener("offline", callback);
  return () => {
    window.removeEventListener("online", callback);
    window.removeEventListener("offline", callback);
  };
}

function getSnapshot(): boolean {
  return typeof navigator !== "undefined" ? navigator.onLine : true;
}

function getServerSnapshot(): boolean {
  return true;
}

export function useOnlineStatus(): boolean {
  return useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);
}
```

3. **Always Rebuild & Restart Daemon Processes**:
   - Next.js server instances in production run built bundles from `.next/`.
   - Modifying source files requires `next build` followed by process reload/restart (`pm2 restart` or `npm run start`).

4. **Cryptographic Seeding & RESTRICT Foreign Key Cleanup**:
   - When seeding auth/demo credentials in PostgreSQL with encrypted envelopes (e.g. AES-GCM NIK cipher, scrypt/HMAC lookup hashes), ensure proper initialization of associated authentication data and version tags rather than raw base64 dummies.
   - When resetting or replacing demo access credentials, cascade child session tables (e.g. `mother_sessions`) first if constrained by foreign key `ON DELETE RESTRICT`.

5. **Cross-Origin Mutation Rejection & Upstream Service Sync**:
   - Next.js BFF API proxy routes rejecting POST mutations with 403 `FORBIDDEN` ("Permintaan lintas situs ditolak") indicates a mismatch between the incoming browser `Origin` header and configured `APP_BASE_URL` in environment / systemd unit files.
   - When restarting background daemon services (`systemd` / `pm2`), verify port collisions (e.g. `EADDRINUSE: :::3000`) and ensure both API backend and Next.js frontend services restart with matching production environment variables (`APP_BASE_URL=https://<domain>`).

6. **Password Visibility Toggle (UX Pattern)**:
   - Always provide accessible password/access-code visibility toggle buttons (`aria-label`, `title`, SVG icons) on authentication forms to eliminate input errors for complex passphrases or base32 access codes. Ensure inputs have sufficient padding-right (`padding-right: 2.75rem`) so toggle buttons do not overlap typed text.

7. **End-to-End Schema & Foreign Key Propagation in Monorepos**:
   - When extending entity registration forms with organizational/hierarchical attributes (e.g. `village_id`, `registration_facility_id`):
     - **Contracts (`packages/contracts`)**: Update both the Zod validation schema (`.optional().nullable()`) and exported TypeScript request/response interfaces, then rebuild dependent package contracts (`npm run build:packages`).
     - **Backend Repository & Service (`apps/api`)**: Update DTO interfaces, SQL `INSERT` columns and parameter bindings.
     - **Frontend UI & Form State (`apps/web`)**: Wire reusable custom fetching hooks (e.g. `useVillages`, `useFacilities`), implement cascading dependencies (e.g. filter facilities by selected village), ensure form reset helpers clear the newly added fields, and include the fields in the pre-submission confirmation/review step.
     - **Verification**: Run workspace-wide typecheck (`npm run typecheck`), unit tests (`npm run test`), linter (`npm run lint`), and rebuild/restart all services.

8. **Strict Zod Contract Alignment in BFF Proxy Mutations**:
   - When APIs use `.strict()` on mutation schemas (e.g. `pregnancyCloseRequestSchema` or `motherRecordArchiveRequestSchema`), extra payload properties (e.g. leftover UI flags like `outcome: "OTHER"`) trigger generic HTTP 400 `VALIDATION_ERROR` ("Permintaan tidak valid").
   - Always verify that frontend `fetch` mutation bodies match the strict contract schema exactly, including required idempotency fields (`idempotency_key: crypto.randomUUID()`).

9. **Clipboard Copy UX with Temporary Feedback**:
   - For sensitive one-time credentials (e.g. generated access codes), always provide a "Salin Kode" button leveraging `navigator.clipboard.writeText(...)` with temporary visual feedback (e.g. button label switches to "Kode Tersalin!" for 3 seconds) and a toast notification fallback.

10. **Interactive Controls Inside Canvas / Graph Nodes (React Flow / xyflow)**:
   - Interactive elements (buttons, inputs, menus) placed inside custom canvas nodes must have `nodrag nopan` utility classes and `e.stopPropagation()` on click handlers. Without `nodrag nopan`, canvas gesture handlers intercept mousedown/click events as pan or node drag actions, preventing buttons from firing.

11. **Key-Driven Remounting for Entity Configuration Modals**:
   - When managing modal dialogs for selected graph entities (nodes, edges, devices), avoid keeping dirty local `useState` across entity switches. Separate the modal shell from the inner form and render `<ModalContent key={entity.id} entity={entity} />`. The unique `key` forces React to cleanly unmount and re-initialize state per entity, preventing stale form state or blank render freezes.

12. **Next.js Dev Server Chunk Cache, WSL Inotify Watcher Pitfall & Hard Refresh**:
   - In Next.js dev mode (`next dev`), client component updates or feature toggle changes can remain cached in `.next/dev/static/chunks/` or in the browser's memory cache.
   - **WSL File Watcher Pitfall on Windows Mounts (`/mnt/c/`, `/mnt/d/`)**: In WSL2, file edits to projects located on Windows drives (`/mnt/`) often fail to emit Linux `inotify` events to Node.js `fs.watch`. Next.js dev / Turbopack silently keeps serving stale in-memory chunks without triggering hot-module reload, leading users to report "belum terload" or missing changes.
   - If an edit on WSL mounted storage does not reflect in the browser: verify chunk contents in `.next/dev/static/chunks/`, stop `next dev`, completely purge `.next` (`rm -rf .next`), restart `next dev`, and instruct the user to hard-refresh (`Ctrl + F5` / `Ctrl + Shift + R`).

13. **Clean Feature Toggles without Code Disposal**:
   - When requested to temporarily hide or deactivate a module without discarding the code:
     - Introduce a top-level boolean flag (e.g. `const ENABLE_FEATURE_XYZ = false;`).
     - Conditionally spread navigation tab definitions (`...(ENABLE_FEATURE_XYZ ? [tabDef] : [])`).
     - Conditionally filter or hide associated dashboard metric cards, priority queue items, and table headers so no dead terminology lingers in the UI.
     - Keep the implementation component file completely intact so re-enabling only requires changing the toggle to `true`.

14. **Proportional Button & Table Action Ergonomics**:
   - Oversized buttons (`min-height: 46-50px` with thick padding) bloat enterprise and public sector data tables.
   - Standardize buttons to compact sizes: main actions at `min-height: 34-36px`, padding `0.38rem 0.85rem`, compact radius (`4-8px`), and table action buttons at `min-height: 28px`, padding `0.22rem 0.55rem`, font `0.76rem` so table rows remain dense and legible.

15. **Dashboard Deduplication & Action Placement**:
   - Avoid rendering duplicate action tables directly under KPI/status metric cards when a dedicated operational queue section already exists on the same page. Keep metric cards purely informational for high-level monitoring, and centralize resolution buttons (e.g. WhatsApp fallback) in the dedicated queue.
   - Position utility actions like "Ekspor CSV/Excel" in the table toolbar or pagination bar next to data count summaries rather than beside the page header's primary creation CTA (`+ Daftarkan Pasien Baru`).

16. **Radio Pills vs. Searchable Combobox for Form Cardinality**:
   - **Low cardinality (2–6 options, e.g. Wilayah Desa)**: Use compact radio pills (`padding: 0.25rem 0.65rem`, height `32px`, font `0.8rem`) in a responsive grid. Never let a small pill group take a 100% width row by itself or use oversized padding, which users perceive as bloated / "kebesaran". Keep it side-by-side with related inputs.
   - **Medium/High or Variable cardinality (8+ options, e.g. Posyandu / TPMB / Faskes)**: Use a **Searchable Dropdown (Combobox)** with an inline search icon, text filter input, clear button (`✕`), and outside-click listener. This gives desktop users instant keyboard filtering while preventing mobile screen clutter from dozens of radio buttons.
   - Pair them in a balanced 2-column grid (`repeat(auto-fit, minmax(280px, 1fr))`) for clean visual symmetry.

17. **Modal Re-Confirmation for Sensitive & External Operational Actions**:
   - For irreversible, status-finalizing, or externally dispatched row actions (e.g. launching external WhatsApp chats, resolving operational queues, marking records as unreachable/failed), never execute on a single raw click.
   - Single-click action buttons in dense data tables are highly susceptible to accidental clicks ("salah pencet") on mobile touchscreens and desktop mice.
   - Always intercept with a focused confirmation modal dialog (`modal-sm`):
     - Display clear entity context in the body: patient/entity name, masked identifier/phone, and schedule/milestone code.
     - State the concrete consequence clearly (e.g. "Antrean ini akan ditandai SELESAI dan dikeluarkan dari daftar").
     - Color-code intent: neutral `btn-secondary` for cancel, `btn-primary` for forward actions, `btn-danger` for terminal failure states.
     - Protect against double-clicks: lock the dialog and show a loading indicator ("Memproses…") with buttons disabled while the async mutation resolves.

18. **Eliminating Technical Audit Disclaimers from Operational Staff UI**:
   - Backend/contract audit disclaimers (e.g. `disclaimer: "Link wa.me ini adalah aksi manual Bidan..."` or audit delivery caveats) belong in API contracts and server logs, not in user-facing staff banners or alert boxes.
   - Clinical and administrative staff find legalistic or architectural disclaimers visually noisy and confusing. Replace technical disclaimers with direct, actionable feedback (e.g. *"Link WhatsApp berhasil dibuka di tab baru"*).

19. **Vite HMR over Reverse Proxy & Cloudflare Tunnel (`clientPort: 443`)**:
   - When running Vite dev server behind an HTTPS reverse proxy (Nginx) or Cloudflare Tunnel, Vite by default instructs client browsers to connect their WebSocket HMR to `location.hostname:5173`.
   - Since public clients (especially remote mobile phones/tablets) only access via HTTPS port 443, HMR fails silently. The mobile browser never receives live module updates or triggers auto-reloads, leading users to report changes "belum terload" / still showing old UI until a full manual cache flush.
   - Fix: In `vite.config.ts`, declare `server: { hmr: { clientPort: 443 } }` and verify Nginx forwards WebSocket headers (`proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade";`).

20. **Mobile Touch Ergonomics on Canvas & Graph Nodes (Beyond Mouse Hover)**:
   - Desktop canvas patterns relying on CSS hover (`group-hover:opacity-100` or floating toolbars positioned above nodes) fail completely on mobile touchscreen devices (iOS Safari, Android Chrome) because touch interactions lack a persistent mouse cursor hover state.
   - Relying solely on node library `selected` props is fragile during touch pan and pinch-zoom gestures.
   - Best practice:
     1. Couple selection state directly with the global application store (`const isSelected = selected || selectedNodeId === id`).
     2. Display a prominent, thumb-reachable **Floating Bottom Context Action Bar** (`absolute bottom-4 sm:bottom-6 left-1/2 -translate-x-1/2 z-30`) whenever a node is selected, featuring color-coded primary actions (e.g. Terminal CLI in emerald, Config in outline, Delete in ghost).
     3. Support double-tap (`onNodeDoubleClick`) on nodes to immediately launch the primary configuration dialog.
     4. Inside configuration dialogs, provide prominent direct-action shortcut buttons (e.g., `[>_ Terminal CLI]`) in both header and footer so mobile users can jump to command prompts without navigating back to canvas.

21. **Pedagogical Network Topology Distribution (Sanitizing Starter IP Configurations)**:
   - When exporting or broadcasting an instructor's reference topology to student workspaces, strictly separate physical hardware layout from logical IP configuration.
   - Students receiving pre-populated IP addresses, subnet masks, and default gateways bypass the educational exercise of subnetting and addressing.
   - Always filter reference node graphs through an explicit sanitization function before loading into student state:
     - Retain node IDs, device roles, canvas coordinates, physical ports, MAC addresses, and link edges.
     - Strip all `ipAddress`, `subnetMask`, `defaultGateway`, port sub-interfaces, and static routing tables so students receive clean, unconfigured hardware.

22. **Exam Integrity Policies via Realtime Broadcast & Local Guards**:
   - In distributed classroom simulators, provide teacher-controlled policy toggles (e.g. `allowSelfCheck: boolean` for Practice Mode vs. Exam Mode).
   - Propagate policy changes instantly across both realtime relay events (`CLASS_SETTINGS_CHANGED`) and local storage subscriptions.
   - Enforce guards defensively on both UI and logic levels:
     - In the student UI, replace the active "Cek Mandiri" button with an informative disabled badge ("Cek Mandiri Dinonaktifkan (Ujian)").
     - In the evaluation handler, reject execution immediately if `allowSelfCheck === false` to prevent inspecting verification targets prior to final submission.




