target "docker-metadata-action" {}

variable "APP" {
  default = "camofox-browser"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=jo-inc/camofox-browser
  default = "1.11.2"
}

variable "UPSTREAM_REF" {
  // renovate: datasource=github-releases depName=jo-inc/camofox-browser
  default = "v1.11.2"
}

variable "SOURCE" {
  default = "https://github.com/jo-inc/camofox-browser"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    CAMOFOX_REF = "${UPSTREAM_REF}"
  }
  labels = {
    "org.opencontainers.image.description" = "Camofox headless browser automation server with the Camoufox anti-detection Firefox fork"
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
