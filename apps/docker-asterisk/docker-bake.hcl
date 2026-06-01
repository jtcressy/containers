target "docker-metadata-action" {}

variable "APP" {
  default = "docker-asterisk"
}

variable "VERSION" {
  default = "asterisk-22.9.0"
}

variable "UPSTREAM_REF" {
  default = "22.9.0"
}

variable "SOURCE" {
  default = "https://github.com/asterisk/asterisk"
}

variable "DEBIAN_SNAPSHOT" {
  default = "20260516T000000Z"
}

variable "ASTERISK_PACKAGE_VERSION" {
  default = "1:22.9.0+dfsg+~cs6.16.60671434-1"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  context = "."
  dockerfile = "Dockerfile"
  args = {
    ASTERISK_PACKAGE_VERSION = "${ASTERISK_PACKAGE_VERSION}"
    DEBIAN_SNAPSHOT          = "${DEBIAN_SNAPSHOT}"
  }
  labels = {
    "org.opencontainers.image.description" = "Dograh Asterisk companion image with ARI, PJSIP, RTP, and websocket modules"
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
    "linux/amd64"
  ]
}
