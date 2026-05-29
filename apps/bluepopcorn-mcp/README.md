# bluepopcorn-mcp

Container image for the MCP-only BluePopcorn server.

```text
ghcr.io/jtcressy/bluepopcorn-mcp
```

## Runtime

The container runs:

```sh
python -m bluepopcorn.mcp
```

Required environment variables:

| Variable | Description |
| --- | --- |
| `SEERR_URL` | Jellyseerr or Overseerr base URL |
| `SEERR_API_KEY` | Jellyseerr or Overseerr API key |
| `MCP_API_KEY` | Bearer token accepted by the MCP HTTP endpoint |

Optional environment variables:

| Variable | Default |
| --- | --- |
| `HTTP_HOST` | `0.0.0.0` |
| `HTTP_PORT` | `8080` |
| `HTTP_TIMEOUT` | `15` |
| `MIN_RATING_VOTES` | `50` |

Endpoints:

| Path | Purpose |
| --- | --- |
| `/mcp` | Streamable HTTP MCP endpoint |
| `/health` | Unauthenticated health check |
