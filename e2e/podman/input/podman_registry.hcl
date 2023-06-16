# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# This job stands up a private container registry for use in e2e tests.
# In a post start task we then upload some default images for convenience.

job "podman_registry" {

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "registry-daemon" {

    network {
      mode = "bridge"
      port "regapi" {
        to = 5000
      }
    }

    service {
      provider = "nomad"
      name     = "registry"
      port     = "regapi"
    }

    task "registry" {
      driver = "podman"

      config {
        image = "docker.io/library/registry:2"
        ports = ["regapi"]
      }

      resources {
        cpu    = 50
        memory = 128
      }
    }
  }

  task "preload" {
    driver = "podman"

    lifecycle {
      hook = "poststart"
      sidecar = false
    }

    config {
      image = "bash:5"
      args = ["whoami"]
    }

    resources {
      cpu = 50
      memory = 32
    }
  }
}
