# Mnemonic V1 MVP Spec

## One-Sentence Product Definition
Mnemonic V1 is a macOS menu bar app that stores per-project memory, values, and decision snapshots locally, then generates a one-click context pack users can paste into Claude/GPT/Cursor, with `.mnm` export/import support.

## Positioning
- Local-first memory/context injection OS layer
- Vendor-agnostic output targets: Claude, GPT, Cursor
- Fast, practical V1 focused on reliable capture and packaging

## In Scope (V1 Required)
- Project separation (`project_id` as primary partition key)
- Menu bar app with ON/OFF, project select, dashboard open
- Rust daemon core with SQLite (WAL) and FTS5
- JSON-RPC over Unix domain socket between app/UI/CLI and daemon
- Event ingest for:
  - Active app/window title
  - Clipboard changes (toggle option)
  - Manual snapshot
- Memory CRUD and pinning
- Context ranking (top 3-5 cards)
- Pack generation without LLM calls:
  - `claude`, `gpt`, `cursor` targets
- One-click copy to clipboard
- `.mnm` export/import (`private` and `share` modes)

## Out of Scope / Prohibited (V1)
- OCR-based screen scraping
- Autonomous keyboard/mouse operation
- Cloud upload/sync
- Account/login system
- Heavy graph DB (e.g., Neo4j)
- Mandatory online dependency for core features

## Non-Functional Requirements
- Daemon idle CPU near 0.x%
- Event ingest with debounce/batch behavior (avoid excessive writes)
- Pack generation target latency: 50-200ms (without LLM)
- Crash isolation between UI shell and core daemon
- Privacy-first filtering for secrets before persistence

## Architecture Baseline
- `Swift AppShell`:
  - Menu bar, permissions, hotkey, daemon lifecycle, keychain hooks
- `Rust Core (daemon: mnmd)`:
  - DB, ingest, ranker, packer, export/import, security, RPC
- `TypeScript UI (React + WebView)`:
  - Feed, Project, Twin Tuning, Export/Import
- Optional `mnm CLI`:
  - Fast operator commands, same daemon/RPC contract

## Acceptance Criteria
1. User can create/select a project and persist memories from dashboard.
2. Active-window/manual events are ingested and visible in recent events.
3. `rankContext` returns a sorted card list for current project context.
4. `generatePack` returns target-specific text and copy action succeeds.
5. `.mnm` export/import round-trips project memory data locally.

