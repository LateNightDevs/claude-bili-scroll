# claude-bili-scroll setup for Windows (PowerShell 5+ or 7).
# Installs the read-only Bilibili MCP server to ~/.bili-mcp, registers it in Claude Code,
# installs the find-something skill to ~/.claude/skills, and (optionally) runs the QR login.
# Safe to run again: it never overwrites your login, rules, taste or seen-list.
$ErrorActionPreference = 'Stop'
$Repo  = $PSScriptRoot
$Home2 = Join-Path $env:USERPROFILE '.bili-mcp'
$Skill = Join-Path $env:USERPROFILE '.claude\skills\find-something'
# The read-only whitelist. Tools not listed here are never registered, so Claude can't see or call them.
$Tools = 'bili_login,bili_login_check,bili_check_credential,bili_recommend,bili_frames,bili_search,bili_hot_videos,bili_hot_buzzwords,bili_weekly_hot,bili_rank,bili_video_info,bili_subtitle,bili_comments'

function Need($cmd, $hint) { if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) { throw "$cmd not found. $hint" } }
Need python 'Install Python 3.10+ (python.org or the Microsoft Store) and reopen the terminal.'
Need node   'Install Node.js 18+ (nodejs.org); the QR login uses it.'
Need claude 'Install Claude Code first (https://claude.com/claude-code).'
$pv = python -c "import sys; print(sys.version_info >= (3,10))"
if ($pv -ne 'True') { throw 'Python 3.10 or newer is needed.' }

Write-Host '1/4  Copying the server to' $Home2
New-Item -ItemType Directory -Force $Home2 | Out-Null
Copy-Item (Join-Path $Repo 'server\*') $Home2 -Force

Write-Host '2/4  Creating the Python environment and installing packages'
$env:PYTHONUTF8 = '1'
if (-not (Test-Path (Join-Path $Home2 '.venv\Scripts\python.exe'))) { python -m venv (Join-Path $Home2 '.venv') }
$Py = Join-Path $Home2 '.venv\Scripts\python.exe'
& $Py -m pip install --disable-pip-version-check -q -r (Join-Path $Home2 'requirements.txt')

Write-Host '3/4  Registering the MCP server "bilibili" in Claude Code (user scope)'
claude mcp remove bilibili -s user 2>$null | Out-Null
$def = @{ type = 'stdio'; command = $Py; args = @((Join-Path $Home2 'mcp_server.py')); env = @{ BILI_MCP_TOOLS = $Tools; PYTHONUTF8 = '1' } } | ConvertTo-Json -Compress
claude mcp add-json bilibili --scope user $def | Out-Null

Write-Host '4/4  Installing the find-something skill to' $Skill
New-Item -ItemType Directory -Force (Join-Path $Skill 'reports') | Out-Null
Copy-Item (Join-Path $Repo 'skill\find-something\SKILL.md') $Skill -Force
Copy-Item (Join-Path $Repo 'skill\find-something\*.template.md') $Skill -Force
foreach ($n in 'rules','taste','seen','later') {
  $f = Join-Path $Skill "$n.md"
  if (-not (Test-Path $f)) { Copy-Item (Join-Path $Skill "$n.template.md") $f }
}

Write-Host ''
if (Test-Path (Join-Path $Home2 'bili_credential.json')) {
  Write-Host 'Already logged in to Bilibili. (Delete ~/.bili-mcp/bili_credential.json to log out.)'
} else {
  $ans = Read-Host 'Log in to Bilibili now with a QR code? (y/n)'
  if ($ans -match '^[yY]') {
    Write-Host 'A QR image will open. Scan it in the Bilibili app (Me > Scan, top right) and confirm. It expires in ~3 minutes.'
    $job = Start-Job { param($h) $env:PYTHONUTF8 = '1'; node (Join-Path $h 'qr_login.mjs') } -ArgumentList $Home2
    $png = Join-Path $Home2 'qrcode_login.png'
    for ($i = 0; $i -lt 30 -and -not (Test-Path $png); $i++) { Start-Sleep 1 }
    if (Test-Path $png) { Start-Process $png }
    Receive-Job $job -Wait -AutoRemoveJob
  }
}

Write-Host ''
Write-Host 'Done. Next:'
Write-Host '  - Restart Claude Code / Claude Desktop so the bilibili tools load.'
Write-Host '  - Say "find me something" - the first time, Claude asks what you like.'
Write-Host '  - Want it every evening? Ask Claude: "schedule find-something every day at 10 PM" (see README).'
Write-Host '  - Check the setup any time:' "$Py $Home2\selftest.py"
