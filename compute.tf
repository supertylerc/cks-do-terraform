resource "digitalocean_ssh_key" "ssh_keys" {
  for_each = var.droplet_ssh_keys

  name       = each.key
  public_key = each.value
}

resource "digitalocean_droplet" "controllers" {
  for_each = var.controllers

  name       = lookup(each.value, "name", each.key)
  region     = var.region
  image      = lookup(each.value, "image", var.default_droplet_image)
  size       = lookup(each.value, "size", var.default_droplet_size)
  ssh_keys   = [for ssh_key in digitalocean_ssh_key.ssh_keys : ssh_key.fingerprint]
  vpc_uuid   = digitalocean_vpc.vpc.id
  monitoring = true
  tags = [
    digitalocean_tag.allow_laptop.id,
    digitalocean_tag.kubernetes_controller.id
  ]
}

resource "digitalocean_droplet" "nodes" {
  for_each = var.nodes

  name       = lookup(each.value, "name", each.key)
  region     = var.region
  image      = lookup(each.value, "image", var.default_droplet_image)
  size       = lookup(each.value, "size", var.default_droplet_size)
  ssh_keys   = [for ssh_key in digitalocean_ssh_key.ssh_keys : ssh_key.fingerprint]
  vpc_uuid   = digitalocean_vpc.vpc.id
  monitoring = true
  tags = [
    digitalocean_tag.allow_laptop.id,
    digitalocean_tag.kubernetes_node.id
  ]
}
