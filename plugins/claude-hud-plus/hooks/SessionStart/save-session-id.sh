#!/bin/bash
# Hook: save-session-id.sh
# Trigger: SessionStart
# Purpose: Save current session ID to a file for external tools (e.g., custom HUD)
#
# SessionEnd Hook will clean this up automatically

set -euo pipefail

# Read stdin (hook JSON input)
if [ -t 0 ]; then
    exit 0
fi

stdin_content=$(cat)

if [ -z "$stdin_content" ]; then
    exit 0
fi

# Extract session_id and cwd from stdin JSON
session_id=$(echo "$stdin_content" | jq -r '.session_id // empty')
cwd=$(echo "$stdin_content" | jq -r '.cwd // empty')

if [ -z "$session_id" ] || [ "$session_id" = "null" ]; then
    exit 0
fi

# Create sessions directory
SESSIONS_DIR="${CLAUDE_DATA_DIR:-$HOME/.claude}/sessions"
mkdir -p "$SESSIONS_DIR"

# Save session info to session-specific file
SESSION_FILE="$SESSIONS_DIR/$session_id.json"
echo "$stdin_content" | jq '{
    session_id: .session_id,
    cwd: .cwd,
    started_at: (now | todate)
}' > "$SESSION_FILE"

# Also update a symlink to the "most recent" session
ln -sf "$session_id.json" "$SESSIONS_DIR/latest.json"

# Output to context for visibility
jq -n --arg sid "$session_id" --arg dir "$SESSIONS_DIR" '{
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": "💾 Session ID: \($sid) | Sessions dir: \($dir)"
    }
}'
