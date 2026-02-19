---
name: handoff-load
description: Load previous session context from context.md or latest .jsonl file
allowed-tools:
  - Bash
  - Read
  - Glob
---

Load context from previous session to resume work.

This will:
1. Check for context.md in ~/.claude/projects/<project>/
2. If found, display it
3. Check for tasks in ~/.claude/tasks/<session_id>/
4. If found, load and display tasks
5. If context.md not found, parse latest .jsonl session file

## 실행 절차

### 1. 프로젝트 경로 확인

```bash
PROJECT_NAME="$(pwd | sed 's/^\///; s/[\/.]/-/g; s/^/-/')"
CONTEXT_FILE="$HOME/.claude/projects/$PROJECT_NAME/context.md"
```

### 2. context.md 로드

```bash
if [ -f "$CONTEXT_FILE" ] && [ -s "$CONTEXT_FILE" ]; then
  echo "📋 Loading context from: $CONTEXT_FILE"
  echo ""
  cat "$CONTEXT_FILE"
else
  echo "📂 context.md not found. Parsing latest session..."
  echo ""
  ${CLAUDE_PLUGIN_ROOT}/scripts/parse-session.sh
fi
```

### 3. tasks 로드

context.md에서 **세션 ID**를 추출해서 해당 세션의 tasks를 로드합니다:

```bash
# context.md에서 세션 ID 추출
SESSION_ID="$(grep "세션 ID:" "$CONTEXT_FILE" 2>/dev/null | sed 's/.*세션 ID: //' | tr -d ' *')"

if [ -n "$SESSION_ID" ] && [ -d "$HOME/.claude/tasks/$SESSION_ID" ]; then
  echo ""
  echo "📋 Tasks from previous session:"
  echo ""

  # tasks 디렉토리의 JSON 파일들 로드
  find "$HOME/.claude/tasks/$SESSION_ID" -name "*.json" -type f | while read -r task_file; do
    echo "📌 $(basename "$task_file" .json)"
    cat "$task_file" | jq -r '. // empty' 2>/dev/null || cat "$task_file"
    echo ""
  done
fi
```

## 출력 형식

```
📋 Loading context from: /home/user/.claude/projects/-home-user-workspace-my-project/context.md

[context.md 내용]

📋 Tasks from previous session:

📌 task-1
[task 내용]

📌 task-2
[task 내용]
```
