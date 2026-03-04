# Mnemonic V1 RPC API (JSON-RPC 2.0)

## Transport
- Unix domain socket (default): `/tmp/mnemonic.sock`
- Encoding: UTF-8 JSON, newline-delimited frames (or length-prefixed; choose one and keep consistent)
- Protocol: JSON-RPC 2.0

## Common Conventions
- Every request includes `"jsonrpc": "2.0"`, `"id"`, `"method"`, `"params"`.
- Timestamps are ISO-8601 UTC (`2026-03-04T07:00:00Z`) unless otherwise noted.
- IDs are UUID strings unless implementation needs integer IDs internally.
- Errors follow JSON-RPC error envelope with typed `code` and message.

## Core Methods (Required)

### `ping`
Request:
```json
{"jsonrpc":"2.0","id":"1","method":"ping","params":{}}
```
Response:
```json
{"jsonrpc":"2.0","id":"1","result":{"ok":true,"version":"0.1.0"}}
```

### `projects.list`
Response `result`:
```json
{
  "projects":[
    {"id":"p1","name":"Mnemonic","createdAt":"2026-03-04T07:00:00Z","isSelected":true}
  ]
}
```

### `projects.create`
Params:
```json
{"name":"Mnemonic","scopeConfig":{"paths":["/Users/me/work/mnemonic"]}}
```
Response:
```json
{"project":{"id":"p1","name":"Mnemonic","createdAt":"2026-03-04T07:00:00Z"}}
```

### `projects.select`
Params:
```json
{"projectId":"p1"}
```
Response:
```json
{"ok":true}
```

### `projects.setScope`
Params:
```json
{"projectId":"p1","scopeConfig":{"paths":["/Users/me/work/mnemonic","/Users/me/docs"]}}
```
Response:
```json
{"ok":true}
```

### `memories.list`
Params:
```json
{"projectId":"p1","type":"decisions","limit":100}
```
Response:
```json
{
  "items":[
    {
      "id":"m1",
      "projectId":"p1",
      "type":"decisions",
      "title":"Use Rust daemon",
      "content":"Daemon isolates crashes from AppShell",
      "pinned":true,
      "createdAt":"2026-03-04T07:00:00Z"
    }
  ]
}
```

### `memories.upsert`
Params:
```json
{
  "projectId":"p1",
  "memory":{
    "id":"m1",
    "type":"values",
    "title":"Local-first privacy",
    "content":"Never upload raw context to cloud",
    "pinned":true
  }
}
```
Response:
```json
{"memoryId":"m1","ok":true}
```

### `memories.delete`
Params:
```json
{"projectId":"p1","memoryId":"m1"}
```
Response:
```json
{"ok":true}
```

### `memories.pin`
Params:
```json
{"projectId":"p1","memoryId":"m1","pinned":true}
```
Response:
```json
{"ok":true}
```

### `events.ingest`
Params:
```json
{
  "projectId":"p1",
  "kind":"active_app",
  "ts":"2026-03-04T07:01:00Z",
  "payload":{
    "appName":"Cursor",
    "windowTitle":"src/ranking.rs - Mnemonic"
  }
}
```
Response:
```json
{"eventId":"e1","sensitivity":"safe"}
```

### `events.listRecent`
Params:
```json
{"projectId":"p1","minutes":10,"limit":200}
```
Response:
```json
{
  "items":[
    {"id":"e1","kind":"active_app","ts":"2026-03-04T07:01:00Z","payload":{"appName":"Cursor"}}
  ]
}
```

### `rankContext`
Params:
```json
{
  "projectId":"p1",
  "nowContext":{
    "activeApp":"Cursor",
    "windowTitle":"ranking.rs",
    "recentMinutes":10
  }
}
```
Response:
```json
{
  "cards":[
    {"id":"c1","sourceKind":"memory","sourceId":"m1","title":"Use Rust daemon","score":0.96},
    {"id":"c2","sourceKind":"event","sourceId":"e9","title":"Recent clipboard snippet","score":0.61}
  ]
}
```

### `generatePack`
Params:
```json
{
  "projectId":"p1",
  "target":"claude",
  "selectedCardIds":["c1","c2"]
}
```
Response:
```json
{
  "packId":"pk1",
  "content":"# Project\nMnemonic...\n# Rules\n...",
  "meta":{"target":"claude","charCount":812}
}
```

### `exportMnm`
Params:
```json
{
  "projectId":"p1",
  "options":{"mode":"share","includeEventsSummary":true}
}
```
Response:
```json
{"filePath":"/Users/me/Downloads/Mnemonic_2026-03-04.mnm","bytes":42120}
```

### `importMnm`
Params:
```json
{
  "filePath":"/Users/me/Downloads/Mnemonic_2026-03-04.mnm",
  "options":{"mergeStrategy":"upsert"}
}
```
Response:
```json
{"projectId":"p2","inserted":{"memories":14,"edges":9,"eventsSummary":33}}
```

## Error Codes (Suggested)
- `-32600`: Invalid request
- `-32601`: Method not found
- `-32602`: Invalid params
- `-32603`: Internal error
- `1001`: Project not found
- `1002`: Permission denied / scope violation
- `1003`: Invalid `.mnm` archive
- `1004`: Sensitive content blocked

