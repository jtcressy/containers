# syntax=docker/dockerfile:1

FROM docker.io/library/debian:sid-slim

ARG DEBIAN_SNAPSHOT=20260516T000000Z
ARG ASTERISK_PACKAGE_VERSION=1:22.9.0+dfsg+~cs6.16.60671434-1

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '%s\n' \
        'Types: deb' \
        "URIs: http://snapshot.debian.org/archive/debian/${DEBIAN_SNAPSHOT}" \
        'Suites: sid' \
        'Components: main' \
        'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' \
        'Check-Valid-Until: no' \
        > /etc/apt/sources.list.d/debian.sources \
    && apt-get -o Acquire::Check-Valid-Until=false update \
    && apt-get install -y --no-install-recommends \
        "asterisk=${ASTERISK_PACKAGE_VERSION}" \
        ca-certificates \
        curl \
        gettext-base \
        procps \
    && rm -rf /var/lib/apt/lists/* \
    && for module in \
        chan_websocket \
        codec_ulaw \
        res_ari \
        res_http_websocket \
        res_pjsip \
        res_websocket_client; do \
            find /usr/lib -path "*/asterisk/modules/${module}.so" -print -quit | grep -q .; \
        done \
    && getent passwd asterisk >/dev/null

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && mkdir -p /etc/asterisk/templates /var/lib/asterisk /var/log/asterisk /var/run/asterisk /var/spool/asterisk \
    && chown -R asterisk:asterisk /etc/asterisk /var/lib/asterisk /var/log/asterisk /var/run/asterisk /var/spool/asterisk

EXPOSE 5060/udp 8088/tcp 10000-20000/udp

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["asterisk", "-f", "-U", "asterisk", "-G", "asterisk", "-vvv"]
