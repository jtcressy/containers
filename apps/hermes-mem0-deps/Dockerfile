# syntax=docker/dockerfile:1

# Build the mem0 self-hosted memory backend's Python dependency set against the
# exact Hermes runtime interpreter (Python 3.13, linux/amd64) so compiled
# wheels such as psycopg2-binary select the matching ABI. The Hermes image
# itself is the builder base, so the interpreter is byte-for-byte identical to
# where these deps are imported at runtime.
#
# Python-version coupling: if upstream Hermes moves off Python 3.13, bump the
# builder base tag below to the matching Hermes release and rebuild — the
# compiled wheels are interpreter-version specific.
FROM nousresearch/hermes-agent:v2026.9.11@sha256:9469b3e78b9545b6d576eb8887a95352e9a0ea83730eaf31431cf862ca1010e1 AS builder

ARG MEM0_VERSION

# uv is a build-only tool (it never ships in the final image), so it is pulled
# from its official distroless image rather than version-pinned here.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Root so --target /pydeps is writable regardless of the base image's user.
USER 0
RUN uv pip install \
        --no-cache \
        --python /opt/hermes/.venv/bin/python \
        --target /pydeps \
        "mem0ai==${MEM0_VERSION}" \
        psycopg2-binary \
        ollama

# Minimal final image: only the dependency tree. Consumed by the Hermes pod as
# a read-only Kubernetes `image` volume and exposed to the gateway's Python via
# PYTHONPATH — nothing in this image is ever executed.
FROM scratch
COPY --from=builder /pydeps /pydeps
