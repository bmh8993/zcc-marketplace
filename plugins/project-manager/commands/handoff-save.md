---
name: handoff-save
description: Save current session context to context.md for next session
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
---

현재 세션의 컨텍스트를 분석해서 context.md에 저장합니다.

## 목적

다른 세션에서 현재 작업을 이어갈 수 있도록 현재 상태를 저장합니다.

## 실행 절차

### 1. 현재 상태 확인

```bash
# 프로젝트 경로 확인
pwd

# Git 정보 확인
git branch --show-current
git log -5 --oneline
git status --short
git diff --stat HEAD~3 2>/dev/null || git diff --stat

# 프로젝트 이름 생성 (전체 경로, 점도 하이픈으로 변환)
PROJECT_NAME="$(pwd | sed 's/^\///; s/[\/.]/-/g; s/^/-/')"
CONTEXT_FILE="$HOME/.claude/projects/$PROJECT_NAME/context.md"

# 현재 세션 ID (.jsonl 파일명에서 추출)
if [[ "$(uname)" == "Darwin" ]]; then
  LATEST_JSONL="$(find "$HOME/.claude/projects/$PROJECT_NAME" -name "*.jsonl" -type f -exec stat -f '%m %N' {} \; 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)"
else
  LATEST_JSONL="$(find "$HOME/.claude/projects/$PROJECT_NAME" -name "*.jsonl" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-)"
fi

SESSION_ID="$(basename "$LATEST_JSONL" .jsonl)"
```

### 2. 현재 세션 분석

현재 세션에서 논의/구현한 내용을 분석하고 요약합니다:
- 주요 작업 내용
- 기술적 결정사항
- 문제 해결 과정
- 구현한 기능들

### 3. 현재 세션 Tasks 확인

```bash
# 현재 세션의 tasks 디렉토리 확인
TASKS_DIR="$HOME/.claude/tasks/$SESSION_ID"
TASKS_EXIST=""

if [ -d "$TASKS_DIR" ] && [ -n "$(ls -A "$TASKS_DIR" 2>/dev/null)" ]; then
  TASKS_EXIST="✅"
  TASK_COUNT=$(find "$TASKS_DIR" -name "*.json" -type f | wc -l | tr -d ' ')
else
  TASKS_EXIST="❌"
fi
```

### 4. context.md 생성

분석한 내용을 바탕으로 context.md를 생성합니다:

```markdown
# Session Context

**저장 시간:** [현재 시간]
**세션 ID:** $SESSION_ID
**프로젝트:** [PROJECT_NAME]

## 현재 작업 상태

- **브랜치:** [BRANCH]
- **마지막 커밋:** [LAST_COMMIT]
- **작업 디렉토리:** [PROJECT_DIR]
- **Tasks:** $TASKS_EXIST ${TASK_COUNT:+($TASK_COUNT tasks)}

## 현재 세션 Tasks
EOF

if [ "$TASKS_EXIST" = "✅" ]; then
  cat >> "$CONTEXT_FILE" << 'EOF'

현재 세션에서 생성된 tasks가 있습니다:
EOF

  find "$TASKS_DIR" -name "*.json" -type f | sort | while read -r task_file; do
    task_name="$(basename "$task_file" .json)"
    task_status="$(jq -r '.status // "pending"' "$task_file" 2>/dev/null)"
    task_subject="$(jq -r '.subject // .description // "No description"' "$task_file" 2>/dev/null)"

    # Convert status to emoji
    case "$task_status" in
      completed) status_emoji="✅" ;;
      in_progress) status_emoji="⏳" ;;
      *) status_emoji="⭕" ;;
    esac

    echo "- **$task_name** [$status_emoji $task_status]: $task_subject" >> "$CONTEXT_FILE"
  done
fi

cat >> "$CONTEXT_FILE" << 'EOF'

## 변경된 파일

```
[git status --short 출력]
```

## 변경 통계

```
[git diff --stat 출력]
```

## 현재 세션 내용

### 주요 작업

[현재 세션에서 한 주요 작업 요약]

### 기술적 결정사항

[현재 세션에서 내린 기술적 결정들]

### 문제 및 해결

[격은 문제들과 해결 방법]

### 구현 내용

[구현한 기능/변경사항]

## 최근 커밋 내역

```
[최근 5개 커밋]
```
```

### 4. 저장

```bash
# context.md 저장
cat > "$CONTEXT_FILE" << 'MD'
[생성된 내용]
MD

echo "✅ Context saved to: $CONTEXT_FILE"
echo "📝 Load with: /handoff-load"
```

## 참고

- context.md는 매번 덮어씌워집니다
- 다음 세션에서 `/handoff-load`로 불러올 수 있습니다
