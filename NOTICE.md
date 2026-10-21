# Third-party code and credits

This project's own files are MIT (see `LICENSE`). It also contains code from:

| File | From | License |
|---|---|---|
| `server/mcp_server.py` | [c1overzz/dsh-bili-scroll](https://github.com/c1overzz/dsh-bili-scroll) `vendor/bilibili-mcp/`, which is based on **bilibili-mcp** by AGI_Ananas | MIT — see `server/LICENSE-dsh-bili-scroll` and `server/LICENSE-bilibili-mcp` |
| `server/login.mjs` | [c1overzz/dsh-bili-scroll](https://github.com/c1overzz/dsh-bili-scroll) `lib/login.mjs` | MIT — see `server/LICENSE-dsh-bili-scroll` |
| `server/requirements.txt` | dsh-bili-scroll's `vendor/bilibili-mcp/requirements.txt` | MIT |

**Changes made here**

- `server/mcp_server.py`: added one read-only tool, `bili_recommend` (the logged-in account's home feed), and made the whitelist safe by default: with no `BILI_MCP_TOOLS` set, only the read-only tools register (upstream registered all of them); fixed `bili_video_info` so it returns the video's tags (upstream read a field that doesn't exist, so tags were always empty). Everything else is as in dsh-bili-scroll.
- The idea of the round — read the real content (subtitles) before judging, stay read-only, keep a seen-list, write a dated report, keep the rules in an editable file — comes from dsh-bili-scroll's `prompts/duty.md`. The skill text here is new.

Please don't contact the dsh-bili-scroll or bilibili-mcp authors about this project; open an issue here instead.
