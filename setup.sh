#!/usr/bin/env bash
# claude-bili-scroll setup for macOS / Linux.
# Installs the read-only Bilibili MCP server to ~/.bili-mcp, registers it in Claude Code,
# installs the find-something skill to ~/.claude/skills, and (optionally) runs the QR login.
# Safe to run again: it never overwrites your login, rules, taste or seen-list.
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"
HOME2="$HOME/.bili-mcp"
SKILL="$HOME/.claude/skills/find-something"
# The read-only whitelist. Tools not listed here are never registered, so Claude can't see or call them.
TOOLS='bili_login,bili_login_check,bili_check_credential,bili_recommend,bili_frames,bili_search,bili_hot_videos,bili_hot_buzzwords,bili_weekly_hot,bili_rank,bili_video_info,bili_subtitle,bili_comments'

need() { command -v "$1" >/dev/null 2>&1 || { echo "$1 not found. $2"; exit 1; }; }
need python3 'Install Python 3.10+.'
need node 'Install Node.js 18+ (the QR login uses it).'
need claude 'Install Claude Code first (https://claude.com/claude-code).'
python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3,10) else 1)' || { echo 'Python 3.10 or newer is needed.'; exit 1; }

echo "1/4  Copying the server to $HOME2"
mkdir -p "$HOME2"
cp -f "$REPO"/server/* "$HOME2"/

echo "2/4  Creating the Python environment and installing packages"
export PYTHONUTF8=1
[ -x "$HOME2/.venv/bin/python" ] || python3 -m venv "$HOME2/.venv"
PY="$HOME2/.venv/bin/python"
"$PY" -m pip install --disable-pip-version-check -q -r "$HOME2/requirements.txt"

echo '3/4  Registering the MCP server "bilibili" in Claude Code (user scope)'
claude mcp remove bilibili -s user >/dev/null 2>&1 || true
DEF=$(printf '{"type":"stdio","command":"%s","args":["%s"],"env":{"BILI_MCP_TOOLS":"%s","PYTHONUTF8":"1"}}' "$PY" "$HOME2/mcp_server.py" "$TOOLS")
claude mcp add-json bilibili --scope user "$DEF" >/dev/null

echo "4/4  Installing the find-something skill to $SKILL"
mkdir -p "$SKILL/reports"
cp -f "$REPO/skill/find-something/SKILL.md" "$SKILL/"
cp -f "$REPO"/skill/find-something/*.template.md "$SKILL/"
for n in rules taste seen later; do [ -f "$SKILL/$n.md" ] || cp "$SKILL/$n.template.md" "$SKILL/$n.md"; done

echo
if [ -f "$HOME2/bili_credential.json" ]; then
  echo 'Already logged in to Bilibili. (Delete ~/.bili-mcp/bili_credential.json to log out.)'
else
  read -r -p 'Log in to Bilibili now with a QR code? (y/n) ' ans
  if [[ "$ans" =~ ^[yY] ]]; then
    echo 'Open the QR image when it appears and scan it in the Bilibili app (我的 → 扫一扫). It expires in ~3 minutes.'
    ( sleep 4; [ -f "$HOME2/qrcode_login.png" ] && { open "$HOME2/qrcode_login.png" 2>/dev/null || xdg-open "$HOME2/qrcode_login.png" 2>/dev/null || true; } ) &
    node "$HOME2/qr_login.mjs" || true
  fi
fi

echo
echo 'Done. Next:'
echo '  - Restart Claude Code / Claude Desktop so the bilibili tools load.'
echo '  - Say "find me something" — the first time, Claude asks what you like.'
echo '  - Want it every evening? Ask Claude: "schedule find-something every day at 10 PM" (see README).'
echo "  - Check the setup any time: $PY $HOME2/selftest.py"
