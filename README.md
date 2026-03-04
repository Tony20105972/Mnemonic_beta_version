# Mnemonic V1

## ⚡ Catchy Tagline
**Stop re-explaining your project to AI. Inject your memory graph in one click.**

Mnemonic V1 is a local-first **Context Engine** for engineers and solo makers who live with Claude, GPT, and Cursor.

## 🧠 Problem & Solution
### Problem
If you use AI all day, you keep losing context:
- You repeat the same project background in every new chat.
- Decisions and values drift across tools.
- Valuable project memory stays trapped in your head or random notes.

### Solution
Mnemonic V1 captures project memory locally (facts, preferences, values, decisions), ranks what matters **right now**, and generates a ready-to-paste context pack for:
- Claude
- GPT
- Cursor

No cloud lock-in. No repetitive prompting. Just fast context injection.

## ✨ Key Features
- 🚀 **1-Click Context Injection**  
  Generate target-specific packs (`claude`, `gpt`, `cursor`) and copy instantly.

- 🔒 **Local-First Privacy by Default**  
  Project data stays on your machine. Sensitive patterns are filtered/masked before persistence.

- 🧩 **Project-Scoped Memory Model**  
  Separate memories by project with pinned decisions, values, and working facts.

- 📦 **Portable `.mnm` Snapshots**  
  Export/import context packs to move or share memory safely (`private` / `share` modes).

## 🏗️ Architecture
Mnemonic V1 uses a high-performance 3-layer architecture:

1. **Swift (macOS AppShell)**  
   Menu bar UX, permissions, hotkeys, daemon lifecycle, packaging.
2. **Rust (Core Engine / Daemon)**  
   SQLite + FTS5, ingest pipeline, ranker, pack generator, `.mnm` serialization.
3. **TypeScript + React (Dashboard UI)**  
   Feed, Project, Twin Tuning, Export/Import in WebView.

```text
Swift AppShell (macOS menu bar)
        ↕ JSON-RPC over Unix Domain Socket
Rust Core Daemon (DB / Ranking / Pack / Export)
        ↕ RPC bridge
TS/React Dashboard (WebView UI)
```

## 🛣️ Roadmap (MVP Sprint 1-4)
### Sprint 1: Foundation
- App shell + dashboard host
- Rust daemon + SQLite schema/migrations
- JSON-RPC wiring
- Project/Memory CRUD

### Sprint 2: Observer
- Active app/window event ingest
- Manual snapshot capture
- Clipboard option + sensitivity filter
- Timeline accumulation

### Sprint 3: Feed + Pack
- `rankContext` scoring pipeline
- `generatePack` templates for Claude/GPT/Cursor
- UI selection + copy flow

### Sprint 4: Portability + Delivery
- `.mnm` export/import
- Scope/privacy controls
- DMG packaging and install-ready distribution

## 🧰 Tech Stack
### Core
- `Rust`
- `rusqlite` (SQLite)
- `FTS5` (full-text search)
- Unix Domain Socket + JSON-RPC

### macOS App
- `Swift`
- `AppKit` (`NSStatusItem`, menu bar)
- macOS Accessibility APIs
- `WKWebView`

### UI
- `TypeScript`
- `React`
- `Vite`

## 📚 Specs (Already Defined)
Detailed product and protocol specs are in `specs/`:

- [MVP Spec](/Users/gimdohyeon/Mnemonic_beta_version/specs/MVP_SPEC.md)
- [RPC API](/Users/gimdohyeon/Mnemonic_beta_version/specs/API_RPC.md)
- [DB Schema](/Users/gimdohyeon/Mnemonic_beta_version/specs/DB_SCHEMA.md)
- [MNM Format](/Users/gimdohyeon/Mnemonic_beta_version/specs/MNM_FORMAT.md)
- [Architecture Diagram (D2)](/Users/gimdohyeon/Mnemonic_beta_version/specs/ARCHITECTURE_V1.d2)
- [Implementation Guide](/Users/gimdohyeon/Mnemonic_beta_version/specs/IMPLEMENTATION_GUIDE.md)

## 🧪 Repo Shape
```text
mnemonic/
  apps/macos/          # Swift AppShell
  core/mnemonic-core/  # Rust daemon + DB + ranking + pack
  ui/dashboard/        # TS/React WebView UI
  specs/               # MVP/API/DB/MNM docs
```
