#!/bin/bash

# load-context.sh - Load context from context.md or parse latest session

set -euo pipefail

PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(echo "$PROJECT_DIR" | sed 's/^\///; s/[\/.]/-/g; s/^/-/')"
CONTEXT_DIR="$HOME/.claude/projects/$PROJECT_NAME"
CONTEXT_FILE="$CONTEXT_DIR/context.md"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if context.md exists
if [ -f "$CONTEXT_FILE" ] && [ -s "$CONTEXT_FILE" ]; then
  echo "📋 Loading context from: $CONTEXT_FILE"
  echo ""
  cat "$CONTEXT_FILE"

  # Extract session ID from context.md (handle markdown **)
  SESSION_ID="$(grep "세션 ID:" "$CONTEXT_FILE" 2>/dev/null | sed 's/^.*\*\*세션 ID:\*\* //' | tr -d ' *')"

  # Load tasks if session ID exists and tasks directory is present
  if [ -n "$SESSION_ID" ] && [ -d "$HOME/.claude/tasks/$SESSION_ID" ]; then
    TASKS_DIR="$HOME/.claude/tasks/$SESSION_ID"
    TASK_COUNT=$(find "$TASKS_DIR" -name "*.json" -type f 2>/dev/null | wc -l | tr -d ' ')

    if [ "$TASK_COUNT" -gt 0 ]; then
      echo ""
      echo "📋 Tasks from previous session ($TASK_COUNT tasks):"
      echo ""

      # List all task files
      find "$TASKS_DIR" -name "*.json" -type f | sort | while read -r task_file; do
        task_name="$(basename "$task_file" .json)"

        # Extract status with jq if available
        if command -v jq >/dev/null 2>&1; then
          task_status="$(jq -r '.status // "pending"' "$task_file" 2>/dev/null)"
          task_subject="$(jq -r '.subject // .description // "No description"' "$task_file" 2>/dev/null)"

          # Convert status to emoji
          case "$task_status" in
            completed) status_emoji="✅" ;;
            in_progress) status_emoji="⏳" ;;
            *) status_emoji="⭕" ;;
          esac

          echo "📌 $task_name [$status_emoji $task_status]"
          echo "   $task_subject"
        else
          echo "📌 $task_name"
          cat "$task_file"
        fi
        echo ""
      done
    fi
  fi
else
  echo "📂 context.md not found. Parsing latest session..."
  echo ""
  "$SCRIPT_DIR/parse-session.sh"
fi
