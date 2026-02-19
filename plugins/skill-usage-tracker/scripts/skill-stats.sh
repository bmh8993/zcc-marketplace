#!/bin/bash
# Skill 사용 통계 분석 스크립트

CLAUDE_DIR="$HOME/.claude"

echo "📊 Skill 사용 통계"
echo ""

find "$CLAUDE_DIR/projects" -name "*.jsonl" -type f 2>/dev/null | \
  xargs grep -h '"name":\s*"Skill"' 2>/dev/null | \
  grep -o '"skill":\s*"[^"]*"' | cut -d'"' -f4 | \
  sort | uniq -c | sort -nr | \
  awk '{printf "%3dx  %s\n", $1, $2}'

echo ""

total=$(find "$CLAUDE_DIR/projects" -name "*.jsonl" -type f 2>/dev/null | \
  xargs grep -h '"name":\s*"Skill"' 2>/dev/null | \
  grep -o '"skill":\s*"[^"]*"' | wc -l | tr -d ' ')

echo "총 $total회의 skill 호출"
