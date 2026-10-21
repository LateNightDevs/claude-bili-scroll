"""Call one Bilibili MCP tool from the command line, through the same server, whitelist and login
Claude Code uses. For sessions where the `bilibili` MCP tools aren't loaded.

  bili.py <tool> [json-args] [--max N]
  bili.py bili_rank '{"category":"game","day":3}'
  bili.py bili_subtitle '{"bvid":"BV1..."}' --max 3000

Only the whitelisted read tools exist; anything else fails as "unknown tool".
--max cuts long text fields (subtitles) to N characters."""
import asyncio, json, os, sys
from pathlib import Path
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

HERE = Path(__file__).parent
TOOLS = ("bili_check_credential,bili_recommend,bili_frames,bili_search,bili_hot_videos,bili_hot_buzzwords,"
         "bili_weekly_hot,bili_rank,bili_video_info,bili_subtitle,bili_comments")


async def call(name, args):
    params = StdioServerParameters(command=sys.executable, args=[str(HERE / "mcp_server.py")],
                                   env={**os.environ, "BILI_MCP_TOOLS": TOOLS, "PYTHONUTF8": "1"})
    async with stdio_client(params, errlog=open(os.devnull, "w")) as (r, w):
        async with ClientSession(r, w) as s:
            await s.initialize()
            res = await s.call_tool(name, args)
            return "\n".join(getattr(c, "text", "") for c in res.content)


def main():
    argv = sys.argv[1:]
    cap = None
    if "--max" in argv:
        i = argv.index("--max")
        cap = int(argv[i + 1])
        del argv[i:i + 2]
    if not argv:
        print(__doc__)
        return 1
    name = argv[0]
    args = json.loads(argv[1]) if len(argv) > 1 else {}
    out = asyncio.run(call(name, args))
    if cap:
        try:
            data = json.loads(out)
            if isinstance(data, dict) and isinstance(data.get("text"), str) and len(data["text"]) > cap:
                data["text"] = data["text"][:cap] + f"…(cut, {len(data['text'])} chars total)"
            out = json.dumps(data, ensure_ascii=False)
        except ValueError:
            out = out[:cap]
    sys.stdout.reconfigure(encoding="utf-8")
    print(out)
    return 0


sys.exit(main())
