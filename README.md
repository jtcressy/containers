# Containers

Personal container image builds for home-lab services and glue that do not have
an upstream image I want to consume directly.

Images are published to GitHub Container Registry under:

```text
ghcr.io/jtcressy/<app>
```

## Images

| App | Image | Upstream |
| --- | --- | --- |
| `bluepopcorn-mcp` | `ghcr.io/jtcressy/bluepopcorn-mcp` | `Averyy/bluepopcorn` |
| `camofox-browser` | `ghcr.io/jtcressy/camofox-browser` | `jo-inc/camofox-browser` |
| `docker-asterisk` | `ghcr.io/jtcressy/docker-asterisk` | Asterisk packaged from a pinned Debian sid snapshot |

## Repository Pattern

Each image lives under `apps/<app>/` and owns its build inputs:

```text
apps/<app>/
  Dockerfile
  docker-bake.hcl
  README.md
  smoke.sh       # optional app-specific smoke check; receives the image ref
```

The `docker-bake.hcl` file is the image contract. It defines:

- `APP`: the GHCR package name.
- `VERSION`: the application version tag.
- `UPSTREAM_REF`: the pinned upstream commit or release reference.
- `SOURCE`: the upstream source repository.
- `image-local`: local single-platform build target.
- `image-all`: release multi-platform build target.

Renovate reads inline annotations in `docker-bake.hcl`. For upstreams without
tags or releases, use Renovate's `git-refs` datasource to pin and update a
branch HEAD commit.

## Local Builds

```sh
task apps:list
task apps:build APP=bluepopcorn-mcp
task apps:smoke APP=bluepopcorn-mcp
task apps:smoke APP=docker-asterisk
```

## Releases

The release workflow builds changed app directories on pushes to `main` and
publishes public images to GHCR. Published tags include:

- `rolling`
- the app `VERSION`
- `upstream-<short upstream sha>`
- `sha-<repository commit>`

For immutable deployments, pin the image digest in downstream manifests.
