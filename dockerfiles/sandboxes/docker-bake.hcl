# dockerfiles/sandboxes/docker-bake.hcl

# Variables for version management
variable "VERSION" {
  default = "1"
}

variable "REGISTRY" {
  default = ""
}

# Common configuration inherited by all targets
target "_common" {
  context = "."
}

# Base sandbox image (foundation)
target "base" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.base"
  tags = ["${REGISTRY}astromech-sbx-base:v${VERSION}"]
}

# Main/Yoda agent
target "yoda" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.yoda"
  tags = ["${REGISTRY}astromech-sbx-yoda:v${VERSION}"]
}

# R2D2 - Development agent
target "r2d2" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.r2d2"
  tags = ["${REGISTRY}astromech-sbx-r2d2:v${VERSION}"]
}

# BB8 - Reconnaissance agent
target "bb8" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.bb8"
  tags = ["${REGISTRY}astromech-sbx-bb8:v${VERSION}"]
}

# C3PO - Protocol agent
target "c3po" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.c3po"
  tags = ["${REGISTRY}astromech-sbx-c3po:v${VERSION}"]
}

# BB9E agent
target "bb9e" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.bb9e"
  tags = ["${REGISTRY}astromech-sbx-bb9e:v${VERSION}"]
}

# CB23 agent
target "cb23" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.cb23"
  tags = ["${REGISTRY}astromech-sbx-cb23:v${VERSION}"]
}

# R5D4 agent
target "r5d4" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.r5d4"
  tags = ["${REGISTRY}astromech-sbx-r5d4:v${VERSION}"]
}

# R4P17 agent
target "r4p17" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.r4p17"
  tags = ["${REGISTRY}astromech-sbx-r4p17:v${VERSION}"]
}

# D0 agent
target "d0" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.d0"
  tags = ["${REGISTRY}astromech-sbx-d0:v${VERSION}"]
}

# L337 agent
target "l337" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.l337"
  tags = ["${REGISTRY}astromech-sbx-l337:v${VERSION}"]
}

# K2S0 agent
target "k2s0" {
  inherits = ["_common"]
  dockerfile = "dockerfiles/sandboxes/Dockerfile.k2s0"
  tags = ["${REGISTRY}astromech-sbx-k2s0:v${VERSION}"]
}

# Build groups
group "default" {
  targets = ["base", "yoda", "r2d2", "bb8", "c3po", "bb9e", "cb23", "r5d4", "r4p17", "d0", "l337", "k2s0"]
}

group "base-only" {
  targets = ["base"]
}

group "new-agents" {
  targets = ["yoda", "bb9e", "cb23", "r5d4", "r4p17", "d0", "l337", "k2s0"]
}

group "existing-agents" {
  targets = ["r2d2", "bb8", "c3po"]
}
