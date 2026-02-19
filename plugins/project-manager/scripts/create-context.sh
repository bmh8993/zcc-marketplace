#!/bin/bash

# create-context.sh - Save current session context to context.md

set -euo pipefail

# Get project directory from current path
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(echo "$PROJECT_DIR" | sed 's/^\///; s/[\/.]/-/g; s/^/-/')"
CONTEXT_DIR="$HOME/.claude/projects/$PROJECT_NAME"
CONTEXT_FILE="$CONTEXT_DIR/context.md"

# Create context directory if it doesn't exist
mkdir -p "$CONTEXT_DIR"

# Get git info
if git rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH="$(git branch --show-current)"
  LAST_COMMIT="$(git log -1 --oneline 2>/dev/null || echo 'No commits yet')"
  CHANGED_FILES="$(git status --short 2>/dev/null || echo '')"
  DIFF_STAT="$(git diff --stat HEAD~3 2>/dev/null || git diff --stat 2>/dev/null || echo 'No diffs')"
else
  BRANCH="N/A"
  LAST_COMMIT="Not a git repo"
  CHANGED_FILES=""
  DIFF_STAT=""
fi

# Generate session ID (use current timestamp)
SESSION_ID="$(date +%s)-$$"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

# Create context.md
cat > "$CONTEXT_FILE" << MD
# Session Context

**저장 시간:** $TIMESTAMP
**세션 ID:** $SESSION_ID
**프로젝트:** $PROJECT_NAME

## 현재 작업 상태

- **브랜치:** $BRANCH
- **마지막 커밋:** $LAST_COMMIT
- **작업 디렉토리:** $PROJECT_DIR

## 변경된 파일

\`\`\`
$CHANGED_FILES
\`\`\`

## 변경 통계

\`\`\`
$DIFF_STAT
\`\`\`

## 메모

현재 세션의 중요한 작업 내용을 여기에 추가하세요.

## 다음 단계

- [ ] 다음에 할 작업 1
- [ ] 다음에 할 작업 2

MD

echo "✅ Context saved to: $CONTEXT_FILE"
echo "📝 Load with: /handoff-load"
