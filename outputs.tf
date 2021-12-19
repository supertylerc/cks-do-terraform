output "public_ips" {
  value = {
    controllers: [
      for droplet in digitalocean_droplet.controllers : droplet.ipv4_address
    ],
    nodes: [
      for droplet in digitalocean_droplet.nodes : droplet.ipv4_address
    ]
  }
}

output "ansible_inventory" {
  value = <<-EOT
[controllers]
%{ for droplet in digitalocean_droplet.controllers ~}
${droplet.ipv4_address}
%{ endfor ~}

[nodes]
%{ for droplet in digitalocean_droplet.nodes ~}
${droplet.ipv4_address}
%{ endfor ~}
EOT
}
