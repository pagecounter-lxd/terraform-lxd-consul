locals {
  consul-map = zipmap(lxd_container.consul.*.id, lxd_container.consul.*.ipv4_address)
}

terraform {
  required_providers {
    lxd = {
      source = "terraform-lxd/lxd"
      version = "1.5.0"
    }
  }
}

resource "lxd_container" "consul" {
  count     = var.consul-count
  name      = "${format("consul%02d", count.index + 1)}-${var.dc-role}"
  image     = "packer-consul"
  ephemeral = false
  profiles  = [var.lxd-profile]

  config = {
    "user.user-data" = templatefile("${path.module}/cloud-init.tpl", {
      dc              = var.dc-name,
      iface           = "eth0",
      consul_count    = var.consul-count,
      consul_server   = "consul01-${var.dc-role}",
      consul_wan_join = var.dc-name == "dc1" ? "" : "consul01-primary"
      license         = var.license
      }
    )
  }

  device {
    name = "consul"
    type = "proxy"
    properties = {
      "connect" = "tcp:127.0.0.1:8500",
      "listen"  = "tcp:0.0.0.0:${8500 + count.index + var.dc-num * 10}"
    }
  }

}

output "hosts" {
  value = local.consul-map
}
