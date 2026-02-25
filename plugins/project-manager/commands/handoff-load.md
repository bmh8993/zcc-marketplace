---
name: handoff-load
description: Load previous session context from context.md or specific session
allowed-tools:
  - Bash
  - Read
  - Glob
---

Load context from previous session to resume work.

This will:
1. Check for context.md in ~/.claude/projects/<project>/
2. If found, display it
3. If session_id argument provided, load that specific session
4. If no context.md and no session_id, load previous session (.jsonl file)

## 실행 절차

### 1. 프로젝트 경로 확인

```bash
PROJECT_NAME="$(pwd | sed 's/^\///; s/[\/.]/-/g; s/^/-/')"
CONTEXT_FILE="$HOME/.claude/projects/$PROJECT_NAME/context.md"
SESSION_DIR="$HOME/.claude/projects/$PROJECT_NAME"

# 인자로 받은 session_id (선택적)
REQUESTED_SESSION_ID="$1"
```

### 2. context.md 로드

```bash
if [ -f "$CONTEXT_FILE" ] && [ -s "$CONTEXT_FILE" ]; then
  echo "📋 Loading context from: $CONTEXT_FILE"
  echo ""
  cat "$CONTEXT_FILE"
elif [ -n "$REQUESTED_SESSION_ID" ]; then
  # 특정 세션 ID 로드
  SESSION_FILE="$SESSION_DIR/${REQUESTED_SESSION_ID}.jsonl"
  if [ -f "$SESSION_FILE" ]; then
    echo "📂 Loading session: $REQUESTED_SESSION_ID"
    echo ""
    # 해당 세션 파일 파싱 (parse-session.sh 로직 활용)
    command -v jq >/dev/null 2>&1 || { echo "❌ jq required" >&2; exit 1; }
    LAST_USER_MSG="$(grep '"type":"user"' "$SESSION_FILE" | tail -1 | jq -r '.message.content' 2>/dev/null || echo 'N/A')"
    LAST_RESPONSE="$(grep '"type":"assistant"' "$SESSION_FILE" | jq -r 'select(.message.content[0].type == "text") | .message.content[0].text' 2>/dev/null | tail -1 || echo 'N/A')"
    echo "**세션:** $REQUESTED_SESSION_ID"
    echo ""
    echo "## 마지막 사용자 메시지"
    echo "$LAST_USER_MSG"
    echo ""
    echo "## 마지막 어시스턴트 응답"
    echo "$LAST_RESPONSE"
  else
    echo "❌ Session file not found: $SESSION_FILE"
  fi
else
  # context.md도 없고 인자도 없으면 이전 세션 로드
  echo "📂 context.md not found. Loading previous session..."
  echo ""
  ${CLAUDE_PLUGIN_ROOT}/scripts/parse-session.sh
fi
```

### 3. tasks 로드

**세션 ID**를 추출해서 해당 세션의 tasks를 로드합니다:

```bash
# 세션 ID 결정 (우선순위: 인자 > context.md)
if [ -n "$REQUESTED_SESSION_ID" ]; then
  SESSION_ID="$REQUESTED_SESSION_ID"
else
  SESSION_ID="$(grep "세션 ID:" "$CONTEXT_FILE" 2>/dev/null | sed 's/.*세션 ID: //' | tr -d ' *')"
fi

if [ -n "$SESSION_ID" ] && [ -d "$HOME/.claude/tasks/$SESSION_ID" ]; then
  echo ""
  echo "📋 Tasks from session: $SESSION_ID"
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

### context.md가 있는 경우
```
📋 Loading context from: /home/user/.claude/projects/-home-user-workspace-my-project/context.md

[context.md 내용]

📋 Tasks from session: abc123-def456-...

📌 task-1
[task 내용]

📌 task-2
[task 내용]
```

### 특정 세션 ID를 지정한 경우
```
📂 Loading session: abc123-def456-...

**세션:** abc123-def456-...

## 마지막 사용자 메시지
[사용자 메시지]

## 마지막 어시스턴트 응답
[어시스턴트 응답]
```

### context.md가 없고 인자도 없는 경우
```
📂 context.md not found. Loading previous session...

📂 Parsing: abc123-def456-....jsonl

[파싱된 세션 정보]
```

## Appendix: Claude Code Memory Locations

이 플러그인은 Claude Code의 표준 메모리 위치를 사용합니다:

| Type | Location | Purpose | Shared |
|------|----------|---------|--------|
| **CLAUDE.md** | `./CLAUDE.md` 또는 `./.claude/CLAUDE.md` | 팀 공유 프로젝트 지침 | ✅ Team |
| **CLAUDE.local.md** | `./CLAUDE.local.md` | 개인 프로젝트 설정 (git-ignored) | ❌ Private |
| **MEMORY.md** | `~/.claude/projects/<project>/memory/MEMORY.md` | 자동 메모리 (최대 200줄 로드) | ❌ Private |
| **.claude/rules/*** | `./.claude/rules/*.md` | 모듈형 프로젝트 규칙 | ✅ Team |
| **context.md** | `~/.claude/projects/<project>/context.md` | 세션 handoff (플러그인 전용) | ❌ Private |

**`<project>` 식별자 생성 방법:**
```bash
# git 저장소 루트에서 프로젝트 식별자 생성
PROJECT_NAME="$(pwd | sed 's/^\///; s/[\/.]/-/g; s/^/-/')"

# 예시:
# /Users/zayden.ok/Desktop/dev-others/zcc-marketplace
# → -Users-zayden-ok-Desktop-dev-others-zcc-marketplace
```

같은 git 저장소 내의 모든 하위 디렉토리는 동일한 `<project>` 디렉토리를 공유합니다.

참고: https://code.claude.com/docs/en/memory
