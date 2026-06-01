#!/usr/bin/env bash
set -euo pipefail

image="${1:?image is required}"

docker run --rm --entrypoint asterisk "${image}" -V | grep -F "Asterisk 22.9.0"

if docker run --rm -e ASTERISK_REQUIRE_UNIFI=false "${image}" true; then
    echo "Expected missing ASTERISK_ARI_PASSWORD to fail" >&2
    exit 1
fi

if docker run --rm \
    -e ASTERISK_REQUIRE_UNIFI=false \
    -e ASTERISK_ARI_PASSWORD=dograh-change-me \
    "${image}" true; then
    echo "Expected default ASTERISK_ARI_PASSWORD to fail" >&2
    exit 1
fi

docker run --rm \
    -e ASTERISK_REQUIRE_UNIFI=false \
    -e ASTERISK_ARI_USERNAME=smoke-ari \
    -e ASTERISK_ARI_PASSWORD=smoke-password \
    -e ASTERISK_HTTP_BINDADDR=127.0.0.1 \
    -e ASTERISK_HTTP_PORT=19088 \
    -e ASTERISK_EXTERNAL_ADDRESS=198.51.100.25 \
    -e ASTERISK_LOCAL_NET=192.168.20.0/24 \
    -e DOGRAH_INBOUND_EXTENSION=7900 \
    -e UNIFI_TALK_ENDPOINT=smoke-talk \
    -e UNIFI_TALK_SIP_SERVER=192.0.2.10 \
    -e UNIFI_TALK_SIP_USERNAME=smoke-user \
    -e UNIFI_TALK_SIP_PASSWORD=smoke-sip-password \
    "${image}" bash -c '
        set -euo pipefail
        grep -F "[smoke-ari]" /etc/asterisk/ari.conf
        grep -F "password = smoke-password" /etc/asterisk/ari.conf
        grep -F "bindaddr = 127.0.0.1" /etc/asterisk/http.conf
        grep -F "bindport = 19088" /etc/asterisk/http.conf
        grep -F "exten => 7900,1" /etc/asterisk/extensions.conf
        grep -F "external_signaling_address = 198.51.100.25" /etc/asterisk/pjsip.conf
        grep -F "external_media_address = 198.51.100.25" /etc/asterisk/pjsip.conf
        grep -F "local_net = 192.168.20.0/24" /etc/asterisk/pjsip.conf
        grep -F "contact = sip:192.0.2.10:5060" /etc/asterisk/pjsip.conf
        grep -F "[smoke-talk-registration]" /etc/asterisk/pjsip.conf
    '

cid="$(docker run -d -e ASTERISK_REQUIRE_UNIFI=false -e ASTERISK_ARI_PASSWORD=smoke-password "${image}")"
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
