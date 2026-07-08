#!/usr/bin/env bash
set -euo pipefail

image="${1:?image is required}"

# The image is a scratch rootfs with no runnable process, so inspect its
# filesystem by creating (not running) a container and copying files out.
# The trailing arg only satisfies `docker create`'s "no command specified"
# check; nothing is ever executed.
tmp="$(mktemp -d)"
cid="$(docker create "${image}" /nonexistent)"
trap 'docker rm -f "${cid}" >/dev/null 2>&1 || true; rm -rf "${tmp}"' EXIT

for path in /pydeps/mem0/__init__.py /pydeps/psycopg2 /pydeps/ollama; do
    if ! docker cp "${cid}:${path}" "${tmp}/" >/dev/null 2>&1; then
        echo "smoke: missing ${path} in ${image}" >&2
        exit 1
    fi
done

echo "smoke: /pydeps contains mem0, psycopg2, and ollama"
