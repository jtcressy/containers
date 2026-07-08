# hermes-mem0-deps

Minimal image carrying the [mem0](https://github.com/mem0ai/mem0) self-hosted
memory backend's Python dependencies (`mem0ai`, `psycopg2-binary`, `ollama`)
for the [Hermes agent](https://huggingface.co/NousResearch). The Hermes
upstream image does not bundle mem0's deps, and this repo deliberately does not
fork the full Hermes image to add them.

```text
ghcr.io/jtcressy/hermes-mem0-deps
```

## Build

The deps are installed with `uv pip install --target /pydeps` against the
**Hermes image itself** as the builder base, so the interpreter is identical to
the runtime (Python 3.13, linux/amd64). `psycopg2-binary` ships a compiled
wheel, so this arch/interpreter match is load-bearing — the image is published
`linux/amd64` only. The final stage is `FROM scratch` and contains only
`/pydeps`; nothing in the image is ever executed.

The `mem0ai` version is pinned in `docker-bake.hcl` (`VERSION`) and Renovate
tracks it via the PyPI datasource.

**Python-version coupling:** if upstream Hermes bumps its interpreter off
Python 3.13, update the builder base tag in `Dockerfile` to the matching Hermes
release and rebuild — the compiled wheels are interpreter-version specific.

## Runtime

This image is not run. It is mounted into the Hermes pod as a read-only
Kubernetes [`image` volume](https://kubernetes.io/docs/concepts/storage/volumes/#image)
and its `/pydeps` directory is placed on the gateway's `PYTHONPATH`:

```yaml
volumes:
  - name: mem0-deps
    image:
      reference: ghcr.io/jtcressy/hermes-mem0-deps:<digest>
      pullPolicy: IfNotPresent
# container:
#   volumeMounts:
#     - name: mem0-deps
#       mountPath: /opt/mem0-deps
#       readOnly: true
#   env:
#     - name: PYTHONPATH
#       value: /opt/mem0-deps
```

Mount at a path outside the Hermes data PVC (`/opt/data`) — an image volume
cannot overlay a PVC subdirectory. For immutable deployments, pin the image by
`@sha256` digest in the downstream manifest.
