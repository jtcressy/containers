# syntax=docker/dockerfile:1

# Fetch the pinned upstream source. The runtime stage below mirrors the
# upstream Dockerfile.ci, which downloads the Camoufox binaries at build time
# instead of expecting pre-downloaded bind mounts.
FROM docker.io/library/debian:bookworm-slim AS src

ARG CAMOFOX_REF

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${CAMOFOX_REF}" \
    https://github.com/jo-inc/camofox-browser.git /src

# Upstream Dockerfile.ci uses node:20-slim, but package.json requires
# node >= 22 and the upstream primary Dockerfile uses node:22-slim.
FROM docker.io/library/node:24-slim

ARG TARGETARCH

# Runtime dependencies for Camoufox (Firefox-based), matching upstream
# Dockerfile.ci: Firefox libraries, Mesa for WebGL software rendering, Xvfb
# virtual display, fonts, and python3 for yt-dlp.
RUN apt-get update && apt-get install -y \
        libgtk-3-0 \
        libdbus-glib-1-2 \
        libxt6 \
        libasound2 \
        libx11-xcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxfixes3 \
        libxi6 \
        libxrandr2 \
        libxrender1 \
        libxss1 \
        libxtst6 \
        libegl1-mesa \
        libgl1-mesa-dri \
        libgbm1 \
        xvfb \
        fonts-liberation \
        fonts-noto-color-emoji \
        fontconfig \
        ca-certificates \
        curl \
        unzip \
        python3-minimal \
    && rm -rf /var/lib/apt/lists/*

# Download the Camoufox browser and yt-dlp. The Camoufox version is read from
# the pinned upstream Dockerfile.ci so the binary always matches the version
# the pinned source release was tested against.
RUN --mount=type=bind,from=src,source=/src,target=/src \
    set -eux; \
    CAMOUFOX_VERSION="$(sed -n 's/^ARG CAMOUFOX_VERSION=//p' /src/Dockerfile.ci)"; \
    CAMOUFOX_RELEASE="$(sed -n 's/^ARG CAMOUFOX_RELEASE=//p' /src/Dockerfile.ci)"; \
    test -n "${CAMOUFOX_VERSION}"; \
    test -n "${CAMOUFOX_RELEASE}"; \
    case "${TARGETARCH}" in \
      amd64) CAMOUFOX_ARCH="x86_64"; YTDLP_SUFFIX="" ;; \
      arm64) CAMOUFOX_ARCH="arm64"; YTDLP_SUFFIX="_aarch64" ;; \
      *) echo "Unsupported arch: ${TARGETARCH}" && exit 1 ;; \
    esac; \
    mkdir -p /root/.cache/camoufox; \
    curl -fSL "https://github.com/daijro/camoufox/releases/download/v${CAMOUFOX_VERSION}-${CAMOUFOX_RELEASE}/camoufox-${CAMOUFOX_VERSION}-${CAMOUFOX_RELEASE}-lin.${CAMOUFOX_ARCH}.zip" \
        -o /tmp/camoufox.zip; \
    # unzip returns exit code 1 for Unicode filename warnings, so tolerate it
    # and verify the browser binary landed instead.
    (unzip -q /tmp/camoufox.zip -d /root/.cache/camoufox || true); \
    chmod -R 755 /root/.cache/camoufox; \
    printf '{"version":"%s","release":"%s"}\n' "${CAMOUFOX_VERSION}" "${CAMOUFOX_RELEASE}" \
        > /root/.cache/camoufox/version.json; \
    test -f /root/.cache/camoufox/camoufox-bin; \
    rm /tmp/camoufox.zip; \
    curl -fSL "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux${YTDLP_SUFFIX}" \
        -o /usr/local/bin/yt-dlp; \
    chmod 755 /usr/local/bin/yt-dlp

WORKDIR /app

COPY --from=src /src/package.json /src/package-lock.json ./
COPY --from=src /src/scripts/ ./scripts/
RUN PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm ci --production

COPY --from=src /src/server.js /src/camofox.config.json ./
COPY --from=src /src/lib/ ./lib/
COPY --from=src /src/plugins/ ./plugins/

# Install plugin system dependencies (x11vnc/noVNC for the VNC plugin, etc.)
RUN sh scripts/install-plugin-deps.sh

ENV NODE_ENV=production
ENV CAMOFOX_PORT=9377

# 9377 control API, 5900 native VNC, 6080 noVNC (VNC ports are only active
# when the VNC plugin is enabled).
EXPOSE 9377 5900 6080

CMD ["sh", "-c", "node --max-old-space-size=${MAX_OLD_SPACE_SIZE:-128} server.js"]
