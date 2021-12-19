locals {
  project_resources = concat(
    [for controller in digitalocean_droplet.controllers : controller.urn],
    [for node in digitalocean_droplet.nodes : node.urn]
  )
}

resource "digitalocean_project" "cks_project" {
  name        = var.project_name
  description = "A project to work on the Certified Kubernetes Security Specialist exam"
  purpose     = "CKS Study Environment"
  environment = "Development"
  resources   = local.project_resources
}
