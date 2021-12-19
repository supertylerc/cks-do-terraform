data "http" "public_ip" {
  url = "https://ipinfo.io/json"
  request_headers = {
    Accept = "application/json"
  }
}

resource "digitalocean_tag" "allow_laptop" {
  name = "allow-laptop"
}

resource "digitalocean_firewall" "allow_laptop" {
  name = "allow-laptop"

  tags = [digitalocean_tag.allow_laptop.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = [jsondecode(data.http.public_ip.body)["ip"]]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = [jsondecode(data.http.public_ip.body)["ip"]]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = [jsondecode(data.http.public_ip.body)["ip"]]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = [jsondecode(data.http.public_ip.body)["ip"]]
  }
}

resource "digitalocean_tag" "kubernetes_node" {
  name = "kubernetes-node"
}

resource "digitalocean_firewall" "kubernetes_node" {
  name = "kubernetes-node"

  tags = [digitalocean_tag.kubernetes_node.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "30000-32767"
    source_addresses = [jsondecode(data.http.public_ip.body)["ip"]]
  }

  inbound_rule {
    protocol    = "tcp"
    port_range  = "10250"
    source_tags = [digitalocean_tag.kubernetes_controller.id]
  }

  outbound_rule {
    protocol         = "tcp"
    port_range       = "6443"
    destination_tags = [digitalocean_tag.kubernetes_controller.id]
  }
}

resource "digitalocean_tag" "kubernetes_controller" {
  name = "kubernetes-controller"
}

resource "digitalocean_firewall" "kubernetes_controller" {
  name = "kubernetes-controller"

  tags = [digitalocean_tag.kubernetes_controller.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "6443"
    source_tags      = [digitalocean_tag.kubernetes_node.id]
    source_addresses = [jsondecode(data.http.public_ip.body)["ip"]]
  }

  outbound_rule {
    protocol         = "tcp"
    port_range       = "10250"
    destination_tags = [digitalocean_tag.kubernetes_node.id]
  }
}

resource "digitalocean_firewall" "allow_dns" {
  name = "allow-dns-out"

  tags = [
    digitalocean_tag.kubernetes_controller.id,
    digitalocean_tag.kubernetes_node.id,
  ]

  outbound_rule {
    protocol              = "udp"
    port_range            = "53"
    destination_addresses = ["0.0.0.0/0"]
  }
}

resource "digitalocean_firewall" "allow_http_https" {
  name = "allow-http-and-https-out"

  tags = [
    digitalocean_tag.kubernetes_controller.id,
    digitalocean_tag.kubernetes_node.id,
  ]

  outbound_rule {
    protocol              = "tcp"
    port_range            = "443"
    destination_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "80"
    destination_addresses = ["0.0.0.0/0"]
  }
}

resource "digitalocean_firewall" "allow_weave" {
  name = "allow-weave"

  tags = [
    digitalocean_tag.kubernetes_controller.id,
    digitalocean_tag.kubernetes_node.id,
  ]

  inbound_rule {
    protocol    = "tcp"
    port_range  = "6781-6783"
    source_tags = [
      digitalocean_tag.kubernetes_controller.id,
      digitalocean_tag.kubernetes_node.id,
    ]
  }

  inbound_rule {
    protocol    = "udp"
    port_range  = "6783-6784"
    source_tags = [
      digitalocean_tag.kubernetes_controller.id,
      digitalocean_tag.kubernetes_node.id,
    ]
  }

  outbound_rule {
    protocol         = "tcp"
    port_range       = "6781-6783"
    destination_tags = [
      digitalocean_tag.kubernetes_controller.id,
      digitalocean_tag.kubernetes_node.id,
    ]
  }

  outbound_rule {
    protocol         = "udp"
    port_range       = "6783-6784"
    destination_tags = [
      digitalocean_tag.kubernetes_controller.id,
      digitalocean_tag.kubernetes_node.id,
    ]
  }
}

resource "digitalocean_firewall" "allow_nodeport" {
  name = "allow-nodeport"

  tags = [
    digitalocean_tag.kubernetes_controller.id,
    digitalocean_tag.kubernetes_node.id,
  ]

  inbound_rule {
    protocol    = "tcp"
    port_range  = "30000-32767"
    source_tags = [
      digitalocean_tag.kubernetes_controller.id,
      digitalocean_tag.kubernetes_node.id,
    ]
    source_addresses = [jsondecode(data.http.public_ip.body)["ip"]]
  }

  outbound_rule {
    protocol         = "tcp"
    port_range       = "30000-32767"
    destination_tags = [
      digitalocean_tag.kubernetes_controller.id,
      digitalocean_tag.kubernetes_node.id,
    ]
  }
}
