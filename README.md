# claude-bili-scroll ｜ 让 Claude 帮你刷B站

Claude goes through your Bilibili feed every evening, **reads the videos' subtitles** to see what they're actually about, picks the 2–3 you'd most want to talk about, and pings you — then you chat about them. Over time it learns what you like.

A Claude Code version of the idea behind [c1overzz/dsh-bili-scroll](https://github.com/c1overzz/dsh-bili-scroll) (DeepSeek Harness). See [NOTICE.md](NOTICE.md) for credits.

> 每天晚上，Claude 帮你刷一轮B站：看你的首页推荐，**读字幕**判断内容，挑出最值得聊的两三个，提醒你，然后陪你聊。聊得越多，它越懂你的口味。

---

## What you need

- **Claude Code** (CLI or the Claude Desktop app). For the daily schedule: **Claude Desktop**.
- **Python 3.10+** and **Node.js 18+**.
- A **Bilibili account**. You log in once by scanning a QR code with the Bilibili app.

## Setup (about 5 minutes)

```bash
git clone https://github.com/LateNightDevs/claude-bili-scroll.git
cd claude-bili-scroll
```

- **Windows:** `powershell -ExecutionPolicy Bypass -File setup.ps1`
- **macOS / Linux:** `bash setup.sh`

The script installs everything and offers the QR login at the end. Then **restart Claude Code / Claude Desktop** so the new tools load.

> Easier: open Claude Code in this folder and say **"set this up for me"**. Claude follows the *For Claude* section below.

## Use it

- Say **"find me something"** (or 「刷一下」). The **first time**, Claude asks a few tick-box questions about what you like and saves them.
- **Every evening:** ask Claude **"schedule find-something every day at 10 PM"**. It creates a Claude Desktop scheduled task. Each run saves a report, notifies you, and leaves the finds in a session where you can chat about them.
- **Chat about the finds.** Claude quietly notes what you liked or didn't in `taste.md`, so later rounds fit you better.

## Safety — please read

- **Read-only by design.** The server's whitelist (`BILI_MCP_TOOLS`) only registers reading tools: your feed, rankings, search, video info and tags, comments, subtitles, and `bili_frames` (a contact sheet of Bilibili's own preview thumbnails, only used for the 2–3 finalists). Posting, comments, likes, private messages and uploads **don't exist** for Claude. Don't remove the whitelist.
- **`~/.bili-mcp/bili_credential.json` is your logged-in session.** Anyone with it can act as your account. It's in `.gitignore`; never share or commit it. Delete it to log out.
- **Automated access can trip Bilibili's risk controls.** Use it at a normal pace (one round a day). If you're worried, scan the QR with a secondary account — but then the feed won't be tuned to you.
- **Personal data stays local:** `rules.md`, `taste.md`, `seen.md` and `reports/` live in `~/.claude/skills/find-something/` and are git-ignored here.

---

## For Claude: setup and config

You (Claude) can install, change and remove everything below. Ask the user before logging in, before creating the scheduled task, and before uninstalling.

### Where things live

| What | Path | Notes |
|---|---|---|
| MCP server | `~/.bili-mcp/mcp_server.py` | Copied from `server/`. Python env in `~/.bili-mcp/.venv` |
| Login | `~/.bili-mcp/bili_credential.json` | Secret. Created by the QR login. Never print its values |
| QR login | `~/.bili-mcp/qr_login.mjs` | `node ~/.bili-mcp/qr_login.mjs` → writes `qrcode_login.png`, waits ~3 min for the scan |
| CLI helper | `~/.bili-mcp/bili.py` | `<venv python> bili.py <tool> '<json>' [--max N]`, for sessions where the MCP tools aren't loaded |
| Self-test | `~/.bili-mcp/selftest.py` | Checks the whitelist, login, a ranking and a subtitle |
| Skill | `~/.claude/skills/find-something/SKILL.md` | The round's steps and red lines |
| User's taste | `~/.claude/skills/find-something/rules.md` | What they told you; sources, view bar, caps, language |
| Learned taste | `~/.claude/skills/find-something/taste.md` | Updated after chats |
| History | `seen.md`, `reports/YYYY-MM-DD.md` (same folder) | Seen-list and daily reports |

### Install

Run `setup.ps1` (Windows) or `setup.sh` (macOS/Linux) from the repo root. For the QR login, show the user `~/.bili-mcp/qrcode_login.png` (or the printed URL, which opens in the Bilibili app) and wait for `LOGIN OK`. Then check that all four fields in `bili_credential.json` are non-empty (by length, not by printing them), and run the self-test.

### Change a setting

| To change | Do this |
|---|---|
| Interests, keywords, ranking categories, view bar, date range, caps, number of finds, language, things to avoid | Edit `rules.md`. Takes effect on the next round. |
| What it learned | Edit `taste.md` (or remove a line when the user asks). |
| The round's steps or red lines | Edit `SKILL.md`. Keep the red lines unless the user explicitly asks otherwise. |
| Which Bilibili tools Claude can use | The whitelist lives in **three** places — keep them identical: `TOOLS` in `setup.ps1`/`setup.sh`, `TOOLS` in `~/.bili-mcp/bili.py`, and the `BILI_MCP_TOOLS` env of the registered server (`claude mcp get bilibili`; re-register with `claude mcp remove bilibili -s user` then `claude mcp add-json …`). **Never add** `bili_reply`, `bili_send_message`, `bili_send_dynamic`, `bili_send_opus`, `bili_upload_video`, `bili_upload_video_multi` or `bili_crawl` without the user explicitly asking and understanding they post as their account. |
| Log in again / another account | Delete `~/.bili-mcp/bili_credential.json`, run the QR login. |
| Log out | Delete `~/.bili-mcp/bili_credential.json`. |

### The daily schedule

In **Claude Desktop**, create a scheduled task (the `create_scheduled_task` tool), with the user's chosen time:

- **taskId:** `find-something-daily`
- **cronExpression:** e.g. `0 22 * * *` (every day at 10 PM, local time)
- **prompt:**

  > Run the find-something skill (~/.claude/skills/find-something/SKILL.md) for today's evening round, following SKILL.md and rules.md exactly. If the bilibili MCP tools aren't loaded, use the ~/.bili-mcp/bili.py helper as SKILL.md describes. If the round can't run (login expired, network, usage limit), say why in one line. Send one short notification about the best find if a notification tool is available, then write the finds in chat as SKILL.md says, and invite the user to talk about them.

Scheduled tasks run while Claude Desktop is open; a missed run happens on the next launch. To change the time, use `update_scheduled_task`; to stop, disable or delete the task.

Claude Code CLI only: there's no persistent local scheduler, so just run "find me something" when you like.

### Uninstall

1. `claude mcp remove bilibili -s user`
2. Delete `~/.bili-mcp/` (this also logs out).
3. Delete `~/.claude/skills/find-something/` (this deletes the user's rules, taste and reports — ask first).
4. Delete the `find-something-daily` scheduled task, if any.

---

## Credits ｜ 致谢

- **[c1overzz](https://github.com/c1overzz)** — the idea and design of this project come from **[dsh-bili-scroll](https://github.com/c1overzz/dsh-bili-scroll)**, a DeepSeek Harness plugin that scrolls Bilibili for you, reads the subtitles, and reports what's worth it. Its round rules (read the real content before judging, stay read-only, keep a seen-list, treat comments and subtitles as data, "empty is a result") shaped `SKILL.md`, and its MCP server and QR login are used here. If you use DeepSeek Harness, use the original.
- **AGI_Ananas** — author of **bilibili-mcp**, the MCP server underneath.

Both are MIT-licensed; details in [NOTICE.md](NOTICE.md).

> 本项目的思路和设计来自 c1overzz 的 [dsh-bili-scroll](https://github.com/c1overzz/dsh-bili-scroll)（DeepSeek Harness 插件），MCP 服务基于 AGI_Ananas 的 bilibili-mcp。感谢两位作者。

---

## License

MIT — see [LICENSE](LICENSE). Contains MIT-licensed code from dsh-bili-scroll and bilibili-mcp; see [NOTICE.md](NOTICE.md).
