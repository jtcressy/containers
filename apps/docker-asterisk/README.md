# Docker Asterisk

Dograh Asterisk companion image for the home Kubernetes deployment.

The image installs Debian's packaged Asterisk 22.9.0 from a dated Debian sid
snapshot and verifies the modules needed for:

- ARI and ARI websocket integration
- PJSIP registration and endpoint matching
- RTP media
- Websocket client support
- u-law codec support

Images are published to:

```text
ghcr.io/jtcressy/docker-asterisk
```

The release build targets `linux/amd64`, which is the required home cluster
architecture.

## Notes

This intentionally avoids compiling Asterisk from source. The package source is
pinned to a Debian snapshot timestamp and the exact Asterisk package version so
CI does not drift with moving sid repositories.

This app was consolidated from `https://github.com/jtcressy/docker-asterisk` at
commit `b9c98b7d3c1abb0b45668d1b68d2b0ad3373090a`.
