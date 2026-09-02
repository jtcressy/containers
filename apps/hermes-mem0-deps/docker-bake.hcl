target "docker-metadata-action" {}

variable "APP" {
  default = "hermes-mem0-deps"
}

variable "VERSION" {
  // renovate: datasource=pypi depName=mem0ai
  default = "2.0.20"
}

variable "UPSTREAM_REF" {
  // renovate: datasource=pypi depName=mem0ai
  default = "2.0.20"
}

variable "SOURCE" {
  default = "https://github.com/mem0ai/mem0"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    MEM0_VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.description" = "mem0 self-hosted memory backend Python deps (mem0ai/psycopg2-binary/ollama) built against the Hermes 3.13 runtime, for mounting into the Hermes pod as a Kubernetes image volume"
    "org.opencontainers.image.source" = "https://github.com/jtcressy/containers"
    "org.opencontainers.image.upstream" = "${SOURCE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:local"]
}

# amd64 only: the deps are built against the linux/amd64 Hermes runtime and
# include a compiled psycopg2-binary wheel, so an arm64 variant would be wrong.
target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64"
  ]
}
