# syntax=docker/dockerfile:1

FROM docker.io/library/python:3.14-slim AS builder

ARG BLUEPOPCORN_REF

ENV PATH="/opt/venv/bin:${PATH}" \
    VIRTUAL_ENV=/opt/venv \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv "${VIRTUAL_ENV}" \
    && pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir "bluepopcorn @ git+https://github.com/Averyy/bluepopcorn.git@${BLUEPOPCORN_REF}"

COPY patches/bluepopcorn-x-api-user.py /tmp/bluepopcorn-x-api-user.py
RUN python /tmp/bluepopcorn-x-api-user.py \
    && rm /tmp/bluepopcorn-x-api-user.py

FROM docker.io/library/python:3.14-slim

ENV HTTP_HOST=0.0.0.0 \
    HTTP_PORT=8080 \
    PATH="/opt/venv/bin:${PATH}" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv

RUN groupadd --gid 10001 app \
    && useradd --uid 10001 --gid 10001 --home-dir /app --create-home --shell /usr/sbin/nologin app

COPY --from=builder /opt/venv /opt/venv

USER 10001:10001
WORKDIR /app
EXPOSE 8080

ENTRYPOINT ["python", "-m", "bluepopcorn.mcp"]
