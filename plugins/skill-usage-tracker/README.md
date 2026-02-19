# Skill Usage Tracker

Track and analyze your skill usage statistics across all Claude Code sessions.

## Features

- 📊 Automatically scans all session history
- 📈 Counts and ranks skills by usage frequency
- 🔍 Simple, text-based output
- ⚡ Fast bash-based implementation

## Installation

### Global Installation (Recommended)

1. Copy the plugin to your global plugins directory:
```bash
cp -r skill-usage-tracker ~/.claude/plugins/
```

2. Restart Claude Code

3. Verify installation:
```bash
/help | grep skill-stats
```

### Alternative: Local Installation

For project-specific installation:
```bash
cp -r skill-usage-tracker /path/to/your/project/.claude-plugin/
```

## Usage

Run the command to see your skill usage statistics:

```
/skill-stats
```

Example output:
```
📊 Skill 사용 통계

 12x  plugin-dev:create-plugin
  8x  feature-dev:feature-dev
  5x  session-wrap:wrap
  3x  superpowers:brainstorming

총 28회의 skill 호출
```

## How It Works

The script searches for all session files in `~/.claude/projects/` and extracts skill invocations by looking for the pattern:
```json
{"name": "Skill", "skill": "plugin-name:skill-name", ...}
```

## Troubleshooting

**Command not found:**
- Verify plugin is in `~/.claude/plugins/skill-usage-tracker/`
- Check that `.claude-plugin/plugin.json` exists
- Restart Claude Code

**No statistics shown:**
- Ensure you have session history in `~/.claude/projects/`
- Check that the script has execute permissions: `chmod +x ~/.claude/plugins/skill-usage-tracker/scripts/skill-stats.sh`

## License

MIT
