# claude-hud-plus

Enhanced HUD for Claude Code with session ID tracking. Shows all claude-hud full features plus current session ID.

## Features

All claude-hud full preset features, plus:

- 🔑 **Session ID Display** - Always shows current session ID in the status line
- 💾 **Automatic Session Tracking** - Hooks automatically track active sessions
- 🗑️ **Cleanup on Session End** - Automatically removes ended session files

## Display Elements

Shows everything from claude-hud full preset:

| Element | Display |
|---------|---------|
| **Model Name** | `[Sonnet 4.5 \| Pro]` |
| **Context Bar** | `████░░░░░░ 45%` |
| **Project Path** | `my-project git:(main*)` |
| **Config Counts** | `2 CLAUDE.md \| 4 rules` |
| **Token Breakdown** | `(in: 45k, cache: 12k)` |
| **Output Speed** | `out: 42.1 tok/s` |
| **Usage Limits** | `5h: 25% \| 7d: 10%` |
| **Session Duration** | `⏱️ 5m` |
| **Tools Activity** | `◐ Edit: file.ts \| ✓ Read ×3` |
| **Agents Status** | `◐ explore [haiku]: Finding code` |
| **Todo Progress** | `▸ Fix bug (2/5 tasks)` |
| **Session ID** | `🆔 abc-123-def` ← **NEW!** |

## Installation

This plugin is part of zcc-marketplace. Install with:

```bash
cd /path/to/zcc-marketplace
/plugin marketplace add ./
/plugin install claude-hud-plus@zcc-marketplace
```

## Session Tracking

### How It Works

1. **SessionStart Hook** - Saves current session ID to `~/.claude/sessions/{session-id}.json`
2. **HUD Display** - Reads and displays session ID from `~/.claude/sessions/latest.json`
3. **SessionEnd Hook** - Removes session file when session ends

### Session Files

```bash
# List all active sessions
ls ~/.claude/sessions/
# Output: abc-123-def.json  xyz-789-uvw.json  latest.json -> abc-123-def.json

# View current session info
cat ~/.claude/sessions/latest.json | jq
# Output:
# {
#   "session_id": "abc-123-def",
#   "cwd": "/Users/zayden.ok/Desktop/project",
#   "started_at": "2026-02-25T14:30:00Z"
# }

# Get just the session ID
cat ~/.claude/sessions/latest.json | jq -r .session_id
# Output: abc-123-def

# Count active sessions
ls ~/.claude/sessions/*.json 2>/dev/null | wc -l
```

### Multiple Sessions

Each active session gets its own file. When a session ends, the SessionEnd Hook removes the corresponding file, so `~/.claude/sessions/` always contains only active, running sessions.

## Directory Structure

```
claude-hud-plus/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── hooks/
│   ├── SessionStart/
│   │   └── save-session-id.sh   # Save session ID to file
│   └── SessionEnd/
│       └── cleanup-session-id.sh # Remove session file on end
└── README.md
```

## Credits

Based on [claude-hud](https://github.com/jarrodwatts/claude-hud) by jarrodwatts.

Enhanced with session ID tracking functionality.

## License

MIT
