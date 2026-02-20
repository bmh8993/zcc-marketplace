#!/bin/bash

# parse-session.sh - Parse latest .jsonl session file and extract context

set -euo pipefail

# Check for jq dependency
command -v jq >/dev/null 2>&1 || { echo "❌ Error: jq is required but not installed. Install with: brew install jq" >&2; exit 1; }

PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(echo "$PROJECT_DIR" | sed 's/^\///; s/[\/.]/-/g; s/^/-/')"
SESSION_DIR="$HOME/.claude/projects/$PROJECT_NAME"

# Find second most recent .jsonl file (previous session)
# We skip the most recent one because that's the current session
if [[ "$(uname)" == "Darwin" ]]; then
  LATEST_JSONL="$(find "$SESSION_DIR" -name "*.jsonl" -type f 2>/dev/null | while read -r file; do
    stat -f '%m %N' "$file"
  done | sort -n | tail -2 | head -1 | cut -d' ' -f2-)"
else
  LATEST_JSONL="$(find "$SESSION_DIR" -name "*.jsonl" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -2 | head -1 | cut -d' ' -f2-)"
fi

if [ -z "$LATEST_JSONL" ] || [ ! -f "$LATEST_JSONL" ]; then
  echo "⚠️  No session files found"
  exit 0
fi

echo "📂 Parsing: $(basename "$LATEST_JSONL")"
echo ""

# Extract last user message - .jsonl structure: {"type":"user", "message":{"role":"user","content":"..."}}
LAST_USER_MSG="$(grep '"type":"user"' "$LATEST_JSONL" | tail -1 | jq -r '.message.content' 2>/dev/null || echo 'N/A')"

# Extract last tool use - .jsonl structure: {"type":"assistant", "message":{"content":[{"type":"tool_use","name":"ToolName",...}]}}
LAST_TOOL="$(grep '"type":"assistant"' "$LATEST_JSONL" | jq -r 'select(.message.content[0].type == "tool_use") | .message.content[0].name' 2>/dev/null | tail -1 || echo 'N/A')"

# Extract last assistant text response
LAST_RESPONSE="$(grep '"type":"assistant"' "$LATEST_JSONL" | jq -r 'select(.message.content[0].type == "text") | .message.content[0].text' 2>/dev/null | tail -1 || echo 'N/A')"

# Get file modification time
if [[ "$(uname)" == "Darwin" ]]; then
  FILE_TIME="$(stat -f '%Sm' -t '%Y-%m-%d %H:%M:%S' "$LATEST_JSONL" 2>/dev/null)"
else
  FILE_TIME="$(stat -c '%y' "$LATEST_JSONL" 2>/dev/null | cut -d'.' -f1)"
fi

# Display extracted context
cat << MD
# Previous Session Context

**세션 파일:** $(basename "$LATEST_JSONL")
**마지막 수정:** $FILE_TIME

## 마지막 사용자 메시지

$LAST_USER_MSG

## 마지막 어시스턴트 응답

$LAST_RESPONSE

## 마지막 실행 도구

**Tool:** $LAST_TOOL

## 참고

전체 세션 파일: \`$LATEST_JSONL\`

MD
