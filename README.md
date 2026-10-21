# claude-bili-scroll ｜ 让 Claude 帮你刷B站

[中文](#中文) · [English](#english)

## 中文

每天晚上，Claude 帮你刷一轮B站：看你的首页推荐，**读字幕**判断内容，挑出最值得聊的两三个，提醒你，然后陪你聊。聊得越多，它越懂你的口味。

想法来自 c1overzz 的 [dsh-bili-scroll](https://github.com/c1overzz/dsh-bili-scroll)（DeepSeek Harness 插件），这里是 Claude Code 版本。致谢见 [NOTICE.md](NOTICE.md)。

### 它能做什么

- **每晚替你刷一轮**：看你自己的首页推荐，先过滤（近期发布、有一定播放量、没推过的），再读标题、字幕和评论。拿不准的会跳过，不会乱编。
- **看画面**：只对最后挑中的两三个，用B站自带的预览缩略图看几张截图，了解场景和气氛，不用下载视频。
- **一次只聊一个**：附上链接，顺着话题往外聊，聊够了再换下一个；没聊完的存进“下次再聊”。
- **你也可以主动分享**：随时把一个B站视频链接发给它，它会读字幕、翻评论，再陪你聊。
- **越聊越懂你**：第一次用会问几道勾选题，之后悄悄记下你喜欢和不喜欢什么，只记规律，不记流水账。
- **只读，而且很贴心**：不发评论、不点赞、不私信；防剧透；每天留一份小报告；看过的不再推。

### 需要什么

- **Claude Code**（命令行或 Claude Desktop 应用）。想要每天定时自动跑，需要 **Claude Desktop**。
- **Python 3.10+** 和 **Node.js 18+**。
- 一个**B站账号**。第一次用B站 App 扫一次二维码登录。
- 想在**手机上收到推送**：手机装好 **Claude App**，并在电脑上给对应的会话打开 **Remote Control**。

### 安装（约 5 分钟）

```bash
git clone https://github.com/LateNightDevs/claude-bili-scroll.git
cd claude-bili-scroll
```

- **Windows：** `powershell -ExecutionPolicy Bypass -File setup.ps1`
- **macOS / Linux：** `bash setup.sh`

脚本会装好所有东西，最后问你要不要扫码登录。然后**重启 Claude Code / Claude Desktop**，新工具才会加载。

> 更省事的办法：在这个文件夹里打开 Claude Code，说一句 **“帮我装这个”**，Claude 会照下面的 *For Claude* 一节去做。

### 怎么用

- 说 **“帮我找点东西”**（或「刷一下」）。**第一次**它会问几道勾选题，了解你喜欢什么，并保存下来。
- **每晚自动跑：** 对 Claude 说 **“每天晚上 10 点自动跑 find-something”**，它会创建一个 Claude Desktop 定时任务。每一轮会存一份报告、通知你，并把挑到的内容留在一个会话里，等你来聊。
- **聊聊挑到的内容。** Claude 会悄悄把你喜欢和不喜欢的记进 `taste.md`，以后挑得更准。

### 安全，请务必看一下

- **设计上就是只读。** 服务端的白名单（`BILI_MCP_TOOLS`）只注册读取类工具：你的首页推荐、排行榜、搜索、视频信息和标签、评论、字幕，以及 `bili_frames`（B站自带预览缩略图拼成的一张图，只对最后挑中的两三个使用）。发评论、点赞、私信、投稿这些功能对 Claude **根本不存在**。请不要去掉这个白名单。
- **`~/.bili-mcp/bili_credential.json` 就是你的登录状态。** 谁拿到它，谁就能以你的账号操作。它已写进 `.gitignore`，绝对不要分享或提交。删掉它就等于退出登录。
- **自动化访问可能触发B站的风控。** 请用正常的节奏（一天一轮）。担心的话可以用小号扫码，不过那样首页推荐就不是按你的口味来的了。
- **个人数据只留在本机：** `rules.md`、`taste.md`、`seen.md` 和 `reports/` 都在 `~/.claude/skills/find-something/` 里，本仓库已将它们加入 git 忽略。

---

## English

Claude goes through your Bilibili feed every evening, **reads the videos' subtitles** to see what they're actually about, picks the 2–3 you'd most want to talk about, and pings you — then you chat about them. Over time it learns what you like.

A Claude Code version of the idea behind [c1overzz/dsh-bili-scroll](https://github.com/c1overzz/dsh-bili-scroll) (DeepSeek Harness). See [NOTICE.md](NOTICE.md) for credits.

### What you need

- **Claude Code** (CLI or the Claude Desktop app). For the daily schedule: **Claude Desktop**.
- **Python 3.10+** and **Node.js 18+**.
- A **Bilibili account**. You log in once by scanning a QR code with the Bilibili app.
- For **phone notifications**: the **Claude app** on your phone, and **Remote Control** turned on for that session on your computer.

### Setup (about 5 minutes)

```bash
git clone https://github.com/LateNightDevs/claude-bili-scroll.git
cd claude-bili-scroll
```

- **Windows:** `powershell -ExecutionPolicy Bypass -File setup.ps1`
- **macOS / Linux:** `bash setup.sh`

The script installs everything and offers the QR login at the end. Then **restart Claude Code / Claude Desktop** so the new tools load.

> Easier: open Claude Code in this folder and say **"set this up for me"**. Claude follows the *For Claude* section below.

### Use it

- Say **"find me something"** (or 「刷一下」). The **first time**, Claude asks a few tick-box questions about what you like and saves them.
- **Every evening:** ask Claude **"schedule find-something every day at 10 PM"**. It creates a Claude Desktop scheduled task. Each run saves a report, notifies you, and leaves the finds in a session where you can chat about them.
- **Chat about the finds.** Claude quietly notes what you liked or didn't in `taste.md`, so later rounds fit you better.

### Safety — please read

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
