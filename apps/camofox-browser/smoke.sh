#!/usr/bin/env bash
set -euo pipefail

image="${1:?image is required}"

cid="$(docker run -d \
    -p 127.0.0.1:9377:9377 \
    "${image}")"
trap 'docker rm -f "${cid}" >/dev/null 2>&1 || true' EXIT

for _ in $(seq 1 30); do
    if curl -fsS http://127.0.0.1:9377/health; then
        exit 0
    fi
    sleep 1
done

docker logs "${cid}" >&2
exit 1
