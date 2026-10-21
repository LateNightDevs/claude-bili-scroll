"""Talks to mcp_server.py over MCP exactly like Claude Code does, with the same whitelist,
and checks: which tools exist, login, a ranking, video info and one subtitle (printed short)."""
import asyncio, json, os, sys
from pathlib import Path
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

HERE = Path(__file__).parent
TOOLS = ("bili_login,bili_login_check,bili_check_credential,bili_recommend,bili_frames,bili_search,bili_hot_videos,"
         "bili_hot_buzzwords,bili_weekly_hot,bili_rank,bili_video_info,bili_subtitle,bili_comments")


def text(r):
    return "\n".join(getattr(c, "text", "") for c in r.content)


async def main():
    params = StdioServerParameters(command=sys.executable, args=[str(HERE / "mcp_server.py")],
                                   env={**os.environ, "BILI_MCP_TOOLS": TOOLS, "PYTHONUTF8": "1"})
    async with stdio_client(params) as (r, w):
        async with ClientSession(r, w) as s:
            await s.initialize()
            names = sorted(t.name for t in (await s.list_tools()).tools)
            print("tools exposed:", len(names), names)
            for bad in ("bili_reply", "bili_send_message", "bili_upload_video", "bili_send_dynamic", "bili_send_opus"):
                print(f"  {bad} hidden:", bad not in names)
            who = json.loads(text(await s.call_tool("bili_check_credential", {})))
            print("login valid:", who.get("logged_in"))
            rank = json.loads(text(await s.call_tool("bili_rank", {"category": "game", "day": 3})))
            vids = rank.get("videos", [])
            print("game ranking:", len(vids), "videos; top:", vids[0]["title"] if vids else "-")
            for v in vids[:8]:
                sub = json.loads(text(await s.call_tool("bili_subtitle", {"bvid": v["bvid"]})))
                if sub.get("text"):
                    print("subtitle OK:", v["bvid"], "|", sub.get("language"), "|", len(sub["text"]), "chars |", sub["text"][:60].replace("\n", " "))
                    break
                print("no subtitle:", v["bvid"], sub.get("message") or sub.get("error"))


asyncio.run(main())
