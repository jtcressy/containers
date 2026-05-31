from __future__ import annotations

from pathlib import Path


ROOT = Path("/opt/venv/lib/python3.12/site-packages/bluepopcorn")


def replace(path: Path, old: str, new: str) -> None:
    text = path.read_text()
    if new in text:
        return
    if old not in text:
        raise RuntimeError(f"Patch target not found in {path}: {old!r}")
    path.write_text(text.replace(old, new, 1))


config = ROOT / "mcp" / "config.py"
replace(
    config,
    '    seerr_api_key: str\n',
    '    seerr_api_key: str\n    seerr_api_user: str = ""\n',
)
replace(
    config,
    '    seerr_api_key = os.environ.get("SEERR_API_KEY", "")\n',
    (
        '    seerr_api_key = os.environ.get("SEERR_API_KEY", "")\n'
        '    seerr_api_user = os.environ.get("SEERR_API_USER", "") or os.environ.get("JELLYSEERR_API_USER", "")\n'
    ),
)
replace(
    config,
    '        seerr_api_key=seerr_api_key,\n',
    '        seerr_api_key=seerr_api_key,\n        seerr_api_user=seerr_api_user,\n',
)

seerr = ROOT / "seerr.py"
replace(
    seerr,
    '        api_key: str | None = None,\n',
    '        api_key: str | None = None,\n        api_user: str | None = None,\n',
)
replace(
    seerr,
    '        self.client = httpx.AsyncClient(\n            timeout=_timeout,\n            headers={"X-Api-Key": _api_key},\n        )\n',
    (
        '        headers = {"X-Api-Key": _api_key}\n'
        '        if api_user:\n'
        '            headers["X-API-User"] = api_user\n'
        '        self.client = httpx.AsyncClient(\n'
        '            timeout=_timeout,\n'
        '            headers=headers,\n'
        '        )\n'
    ),
)

mcp_http_app = ROOT / "mcp" / "http" / "app.py"
replace(
    mcp_http_app,
    '        api_key=config.seerr_api_key,\n',
    '        api_key=config.seerr_api_key,\n        api_user=config.seerr_api_user,\n',
)

mcp_server = ROOT / "mcp" / "server.py"
replace(
    mcp_server,
    '        api_key=config.seerr_api_key,\n',
    '        api_key=config.seerr_api_key,\n        api_user=config.seerr_api_user,\n',
)
