# camofox-browser

Container image for [Camofox](https://github.com/jo-inc/camofox-browser), a
Node.js browser automation server built on the
[Camoufox](https://github.com/daijro/camoufox) anti-detection Firefox fork.
Used as the local browser backend for the Hermes agent, which has no published
upstream registry image.

```text
ghcr.io/jtcressy/camofox-browser
```

## Build

Upstream's default build expects Camoufox binaries pre-downloaded into a bind
mount (`make up`). This image instead mirrors upstream's `Dockerfile.ci`,
which downloads the Camoufox browser and yt-dlp at build time. The source is
cloned at the release tag pinned in `docker-bake.hcl`, and the Camoufox
browser version is read from the pinned source's `Dockerfile.ci` so the
binary always matches the pinned release.

Upstream is MIT licensed (Copyright (c) 2025 Jo, Inc).

## Runtime

The container runs the Camofox control server:

```sh
node server.js
```

Optional environment variables:

| Variable | Default | Description |
| --- | --- | --- |
| `CAMOFOX_PORT` | `9377` | Control API port |
| `CAMOFOX_API_KEY` | unset | Bearer token gating cookie import; cookie requests are rejected when unset |
| `CAMOFOX_PROFILE_DIR` | `/root/.camofox` | Session persistence (cookies, localStorage) |
| `ENABLE_VNC` | unset | Enable the VNC plugin for interactive sessions |
| `VNC_RESOLUTION` | `1920x1080` | Virtual display resolution |
| `MAX_OLD_SPACE_SIZE` | `128` | Node.js heap limit in MiB |

Ports:

| Port | Purpose |
| --- | --- |
| `9377` | Control API (`/health` is unauthenticated; OpenAPI docs at `/docs`) |
| `5900` | Native VNC (VNC plugin only) |
| `6080` | noVNC web client at `/vnc.html` (VNC plugin only) |

Mount a volume at `/root/.camofox` to persist sessions across restarts.
