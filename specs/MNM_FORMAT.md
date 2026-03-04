# Mnemonic `.mnm` Format Spec (V1)

## Container
- Extension: `.mnm`
- Physical format: ZIP archive
- Goal: local backup/share transport for project knowledge

## Archive Layout
```text
project.mnm
  manifest.json
  memories.json
  edges.json
  events_summary.json   (optional)
  attachments/          (optional)
```

## `manifest.json`
```json
{
  "version": "1.0",
  "created_at": "2026-03-04T07:00:00Z",
  "redaction_level": "private",
  "project": {
    "id": "p1",
    "name": "Mnemonic_V1"
  },
  "counts": {
    "memories": 24,
    "edges": 15,
    "events_summary": 40
  }
}
```

## `memories.json`
- Array of memory records
- Required keys:
  - `id`, `type`, `title`, `content`, `pinned`, `created_at`, `updated_at`
- `project_id` may be omitted for portability; importer remaps to destination project

## `edges.json`
- Array of edge records
- Required keys:
  - `id`, `src_kind`, `src_id`, `dst_kind`, `dst_id`, `relation`, `weight`, `ts`

## `events_summary.json` (Optional)
- Redacted, summarized timeline only (no raw clipboard secrets)
- Intended for context hints, not full telemetry replay

## Export Modes
- `private`
  - Full local data allowed (subject to user setting)
- `share`
  - Apply redaction/masking policy
  - Remove blocked items and non-exportable memories

## Import Rules
- Validate archive integrity and required files
- Validate `manifest.version` compatibility
- Merge strategy:
  - `upsert` by record `id` default
  - generate new `project_id` unless user selects merge-into-existing
- Report inserted/updated/skipped counts

## Security Notes (V1)
- No mandatory signing/encryption in V1
- Keep extension points in manifest for V2:
  - `signature`
  - `encryption`
  - `key_id`

