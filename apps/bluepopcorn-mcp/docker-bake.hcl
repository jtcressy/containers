target "docker-metadata-action" {}

variable "APP" {
  default = "bluepopcorn-mcp"
}

variable "VERSION" {
  default = "0.1.0"
}

variable "UPSTREAM_REF" {
  // renovate: datasource=git-refs packageName=https://github.com/Averyy/bluepopcorn depName=Averyy/bluepopcorn currentValue=main
  default = "71ef29fbe1f0f319a4e1ff2041360bc78d442214"
}

variable "SOURCE" {
  default = "https://github.com/Averyy/bluepopcorn"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    BLUEPOPCORN_REF = "${UPSTREAM_REF}"
  }
  labels = {
    "org.opencontainers.image.description" = "BluePopcorn MCP server packaged as a standalone HTTP container"
    "org.opencontainers.image.source" = "https://github.com/jtcressy/containers"
    "org.opencontainers.image.upstream" = "${SOURCE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:local"]
}

target "image-all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
