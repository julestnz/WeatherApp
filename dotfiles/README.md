# Jules's Claude Code status line

Shows: `directory (branch) [model] ctx:% used/left $cost`

## Install (Halcy)

1. Copy the script into your Claude config dir:
   ```bash
   cp dotfiles/statusline-command.sh ~/.claude/statusline-command.sh
   chmod +x ~/.claude/statusline-command.sh
   ```

2. Add this to `~/.claude/settings.json` (merge with what's there):
   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "bash ~/.claude/statusline-command.sh"
     }
   }
   ```

3. Restart Claude Code.
