# Mnemonic V1 DB Schema (SQLite)

## Engine Settings
- SQLite with `WAL` journal mode
- Foreign keys enabled
- Busy timeout enabled (e.g., 3-5s)

## Migration Policy
- Keep migrations append-only and numbered:
  - `0001_init.sql`
  - `0002_add_fts.sql`
  - ...
- Never edit a released migration file.
- New schema change must include:
  - Forward migration SQL
  - Backfill strategy (if needed)
  - Compatibility note for daemon startup

## Tables

### `projects`
```sql
CREATE TABLE IF NOT EXISTS projects (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TEXT NOT NULL,
  scope_config_json TEXT NOT NULL DEFAULT '{}',
  selected INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_projects_selected ON projects(selected);
```

### `events`
```sql
CREATE TABLE IF NOT EXISTS events (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  ts TEXT NOT NULL,
  kind TEXT NOT NULL CHECK(kind IN ('active_app','clipboard','file_open','manual_snapshot')),
  payload_json TEXT NOT NULL,
  payload_text TEXT NOT NULL DEFAULT '',
  sensitivity TEXT NOT NULL CHECK(sensitivity IN ('safe','masked','blocked')),
  FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_events_project_ts ON events(project_id, ts DESC);
CREATE INDEX IF NOT EXISTS idx_events_kind ON events(kind);
```

### `memories`
```sql
CREATE TABLE IF NOT EXISTS memories (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  type TEXT NOT NULL CHECK(type IN ('facts','preferences','values','decisions')),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  pinned INTEGER NOT NULL DEFAULT 0,
  exportable INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_memories_project_type_pinned
  ON memories(project_id, type, pinned DESC, updated_at DESC);
```

### `edges`
```sql
CREATE TABLE IF NOT EXISTS edges (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  src_kind TEXT NOT NULL,
  src_id TEXT NOT NULL,
  dst_kind TEXT NOT NULL,
  dst_id TEXT NOT NULL,
  relation TEXT NOT NULL,
  weight REAL NOT NULL DEFAULT 1.0,
  ts TEXT NOT NULL,
  FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_edges_project_src ON edges(project_id, src_kind, src_id);
CREATE INDEX IF NOT EXISTS idx_edges_project_dst ON edges(project_id, dst_kind, dst_id);
```

### `packs`
```sql
CREATE TABLE IF NOT EXISTS packs (
  id TEXT PRIMARY KEY,
  project_id TEXT NOT NULL,
  ts TEXT NOT NULL,
  target TEXT NOT NULL CHECK(target IN ('claude','gpt','cursor')),
  content TEXT NOT NULL,
  meta_json TEXT NOT NULL DEFAULT '{}',
  FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_packs_project_ts ON packs(project_id, ts DESC);
```

## Full-Text Search
- Use FTS5 for searchable memory/event text.
- Keep raw JSON in base table; store extracted text in FTS virtual tables.

```sql
CREATE VIRTUAL TABLE IF NOT EXISTS memories_fts
USING fts5(memory_id UNINDEXED, project_id UNINDEXED, content, tokenize='unicode61');

CREATE VIRTUAL TABLE IF NOT EXISTS events_fts
USING fts5(event_id UNINDEXED, project_id UNINDEXED, payload_text, tokenize='unicode61');
```

## Trigger Suggestions
- Upsert/delete sync triggers from `memories` -> `memories_fts`
- Insert/delete sync triggers from `events` -> `events_fts`

## Performance Notes
- Batch writes for high-frequency event ingestion.
- Debounce active window changes to avoid write storms.
- Keep pack generation read-path index-friendly (`project_id`, `ts`, `pinned`).

