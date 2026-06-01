#!/usr/bin/env bash
set -euo pipefail

image="${1:?image is required}"

docker run --rm --entrypoint asterisk "${image}" -V | grep -F "Asterisk 22.9.0"

cid="$(docker run -d -e ASTERISK_REQUIRE_UNIFI=false "${image}")"
trap 'docker rm -f "${cid}" >/dev/null 2>&1 || true' EXIT

for _ in $(seq 1 30); do
    if docker exec "${cid}" asterisk -rx 'core show version' >/dev/null 2>&1; then
        docker exec "${cid}" asterisk -rx 'module show like res_ari' | grep -F "res_ari.so"
        docker exec "${cid}" asterisk -rx 'module show like res_pjsip' | grep -F "res_pjsip.so"
        exit 0
    fi
    sleep 1
done

docker logs "${cid}" >&2
exit 1
