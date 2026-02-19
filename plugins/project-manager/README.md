# project-manager

Session-to-session context handoff and enhanced memory management for Claude Code.

Based on [team-attention/session-wrap](https://github.com/anthropics/team-attention-plugins) with extended memory management.

## Features

### Core Features

- 🔄 **Context Handoff** - Save current session and resume in next session
- 📝 **Smart Context** - Automatically extracts git status, files, and work state
- 🔍 **Session Parsing** - Fallback to parsing .jsonl session files
- 🧠 **Enhanced Memory Management** - Update all Claude Code memory types

### Session Wrap (from team-attention)

- **Multi-Agent Analysis Pipeline**: 5 specialized agents analyze your session
- **2-Phase Architecture**: Parallel analysis followed by sequential validation
- **Documentation Updates**: Enhanced doc-updater handles 5 memory types
- **Automation Discovery**: Find patterns worth automating
- **Learning Capture**: Extract insights in TIL format
- **Follow-up Planning**: Prioritized task list for next session

## Installation

This plugin is part of zcc-marketplace. Install with:

```bash
cd /path/to/zcc-marketplace
/plugin marketplace add ./
/plugin install project-manager@zcc-marketplace
```

## Usage

### Handoff Commands

#### Quick Save

```bash
/handoff-save
```

Saves current session context to `~/.claude/projects/<project>/context.md`

**What gets saved:**
- Current git status (branch, commits, changed files)
- Work directory
- Timestamp and session ID
- Notes and next steps sections

#### Quick Load

```bash
/handoff-load
```

Loads context from `context.md` or parses latest `.jsonl` session file

**What gets loaded:**
- Previous session summary
- Last work state
- Next steps to continue

### Session Wrap

```bash
/wrap [optional commit message]
```

Runs the full wrap-up workflow:
1. Check git status
2. Phase 1: Run 4 analysis agents in parallel
3. Phase 2: Validate proposals
4. Present results and let you choose actions
5. Execute selected actions

## Enhanced Memory Management

The enhanced `doc-updater` agent handles all 5 Claude Code memory types:

| Type | Location | Purpose |
|------|----------|---------|
| **CLAUDE.md** | Project root | Project memory (team-shared, git-tracked) |
| **CLAUDE.local.md** | Project root | Personal settings (git-ignored) |
| **MEMORY.md** | `~/.claude/projects/<project>/memory/` | Auto-memory (max 200 lines) |
| **.claude/rules/*** | Project root | Modular project rules |
| **context.md** | `~/.claude/projects/<project>/` | Session handoff |

## Context Location

Context is stored in Claude Code's project directory:

```
~/.claude/projects/<project-name>/context.md
```

## Context Format

```markdown
# Session Context

**저장 시간:** 2026-02-15 14:30:00
**세션 ID:** 1234567890-12345
**프로젝트:** my-project

## 현재 작업 상태

- **브랜치:** feature/new-feature
- **마지막 커밋:** abc1234 Add feature
- **작업 디렉토리:** /path/to/project

## 변경된 파일

M  src/file1.js
A  src/file2.js

## 변경 통계

src/file1.js | 5 +-
src/file2.js | 10 ++++

## 메모

현재 세션의 중요한 작업 내용을 여기에 추가하세요.

## 다음 단계

- [ ] 완료할 작업 1
- [ ] 완료할 작업 2
```

## Workflow

```
Working Session A
    ↓
/handoff-save (end of day)
    ↓
Context saved to context.md
    ↓
Next Day - Session B starts
    ↓
/handoff-load
    ↓
Work resumed from where you left off
```

## Agents

| Agent | Purpose |
|-------|---------|
| **doc-updater** (enhanced) | Analyze documentation needs for all 5 memory types |
| **automation-scout** | Detect automation opportunities |
| **learning-extractor** | Extract learnings and mistakes |
| **followup-suggester** | Suggest prioritized follow-up tasks |
| **duplicate-checker** | Validate proposals for duplicates |

## Coming Soon

- **handoff skill** - Interactive handoff with options
- **context.md integration** in `/wrap` workflow
- **Smart memory suggestions** based on session content

## Directory Structure

```
project-manager/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── commands/
│   ├── wrap.md                  # /wrap command (from session-wrap)
│   ├── handoff-save.md          # /handoff-save command
│   └── handoff-load.md          # /handoff-load command
├── agents/
│   ├── doc-updater.md           # Enhanced: 5 memory types
│   ├── automation-scout.md      # Automation detection
│   ├── learning-extractor.md    # Learning capture
│   ├── followup-suggester.md    # Task prioritization
│   └── duplicate-checker.md     # Validation
├── skills/
│   ├── session-wrap/            # Session wrap best practices
│   ├── history-insight/         # Session history analysis
│   └── session-analyzer/         # Post-hoc session validation
├── scripts/
│   ├── create-context.sh        # Save context to context.md
│   ├── parse-session.sh         # Parse .jsonl session files
│   └── load-context.sh          # Load context from context.md or .jsonl
└── README.md
```

## Credits

Based on [team-attention/session-wrap](https://github.com/anthropics/team-attention-plugins) by Anthropic.

Enhanced with handoff functionality and expanded memory management.

## License

MIT
