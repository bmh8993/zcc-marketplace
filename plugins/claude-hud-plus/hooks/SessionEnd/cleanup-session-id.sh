#!/bin/bash
# Hook: cleanup-session-id.sh
# Trigger: SessionEnd
# Purpose: Clean up session file when session ends

set -euo pipefail

# Read stdin (hook JSON input)
if [ -t 0 ]; then
    exit 0
fi

stdin_content=$(cat)

if [ -z "$stdin_content" ]; then
    exit 0
fi

# Extract session_id from stdin JSON
session_id=$(echo "$stdin_content" | jq -r '.session_id // empty')

if [ -z "$session_id" ] || [ "$session_id" = "null" ]; then
    exit 0
fi

# Remove session file
SESSIONS_DIR="${CLAUDE_DATA_DIR:-$HOME/.claude}/sessions"
SESSION_FILE="$SESSIONS_DIR/$session_id.json"

if [ -f "$SESSION_FILE" ]; then
    rm -f "$SESSION_FILE"

    # Also remove latest symlink if it points to this session
    LATEST_FILE="$SESSIONS_DIR/latest.json"
    if [ -L "$LATEST_FILE" ]; then
        LINK_TARGET=$(readlink "$LATEST_FILE")
        if [ "$LINK_TARGET" = "$session_id.json" ]; then
            rm -f "$LATEST_FILE"
        fi
    fi
fi

# Optional: Output to context for visibility
jq -n --arg sid "$session_id" '{
    "hookSpecificOutput": {
        "hookEventName": "SessionEnd",
        "additionalContext": "🗑️ Session cleaned up: \($sid)"
    }
}'
