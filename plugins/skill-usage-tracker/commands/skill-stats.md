---
name: skill-stats
description: Display skill usage statistics across all Claude Code sessions
allowed-tools:
  - Bash
---

Execute the skill usage statistics script to show skill call counts and rankings.

Run the script at ${CLAUDE_PLUGIN_ROOT}/scripts/skill-stats.sh

The script will:
1. Search for all session files in ~/.claude/projects
2. Extract skill invocation patterns
3. Count and rank skills by usage frequency
4. Display results in a formatted table

No arguments are required - simply execute the script and present the output to the user.
