# Mnemonic V1 Implementation Guide (for Codex)

## Repo Layout (Target)
```text
mnemonic/
  apps/
    macos/
      MnemonicApp.xcodeproj
      Sources/
        AppShell/
        IPC/
        Permissions/
        Packaging/
  core/
    mnemonic-core/
      src/
        db/
        ingest/
        ranking/
        pack/
        export/
        security/
        rpc/
  ui/
    dashboard/
      src/
        pages/
        components/
        api/
  specs/
    MVP_SPEC.md
    API_RPC.md
    DB_SCHEMA.md
    MNM_FORMAT.md
```

## Execution Order (Do not skip)
1. Rust daemon + RPC server + DB migration
2. Swift IPC client + daemon lifecycle manager
3. TS UI for project/memory CRUD
4. Observer for active window + manual snapshot
5. `rankContext` + `generatePack`
6. `.mnm` export/import (+ optional CLI commands)

## Sprint Acceptance Criteria

### Sprint 1: Foundation
- Implement daemon startup and `ping` RPC.
- Apply DB migrations on boot.
- Complete `projects.*` and `memories.*` RPC methods.
- UI can create/select project and upsert/list memory.

### Sprint 2: Event Ingest
- Collect active app/window title with debounce.
- Manual snapshot action writes event.
- Clipboard ingest obeys settings toggle.
- Sensitive pattern filter masks/blocks before DB write.

### Sprint 3: Feed + Pack
- `rankContext` returns 3-5 cards sorted by score.
- `generatePack` supports `claude`, `gpt`, `cursor`.
- UI supports card selection and copy-to-clipboard.
- End-to-end pack generation works without LLM call.

### Sprint 4: Portability + Packaging
- Export `.mnm` with `private/share` modes.
- Import `.mnm` with upsert merge strategy.
- Scope settings and privacy controls exposed in UI.
- Installable app package (DMG) produced.

## Codex Prompt Templates

### Prompt 1: Core Daemon & DB
Implement `mnemonic-core` in Rust with SQLite (`rusqlite`) and WAL mode. Add migration logic for `projects`, `events`, `memories`, `edges`, `packs` per `DB_SCHEMA.md`. Build JSON-RPC server over Unix socket with `ping` and `projects.create`.

### Prompt 2: Observer & Ingest
In Swift, track active app + window title every 1 second and emit only on change. Send events to `events.ingest`. In Rust, mask API key/token/password patterns before persistence.

### Prompt 3: Ranker & Pack
Implement `rankContext` with recency/project/pinned weighting and return top 5 cards. Implement `generatePack` template output for `claude/gpt/cursor`. In TS UI, show cards and copy generated pack.

### Prompt 4: CLI & `.mnm`
Build `mnm` CLI that talks to daemon over socket (`mnm log`, `mnm pack`). Implement `.mnm` zip export/import based on `MNM_FORMAT.md`.

