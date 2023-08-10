resource "tls_private_key" "multi-cloud" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "random_string" "random" {
  length  = 8
  special = false
  lower   = true
}


resource "local_file" "rsa_private_key" {
  content         = tls_private_key.multi-cloud.private_key_openssh
  filename        = "rsa_private_key"
  file_permission = "0600"
}

resource "local_file" "rsa_private_key_2" {
  content         = tls_private_key.multi-cloud.private_key_openssh
  filename        = "./ansible/rsa_private_key"
  file_permission = "0600"
}

resource "local_file" "vars" {
  filename = "./ansible/vars.yml"
  content = templatefile(
    "./locals/vars.tftpl",
    {
      ne_ip = equinix_network_device.multi-cloud-router.ssh_ip_address
      ssh_user = var.ssh_user
      ssh_password = var.ssh_password
      ne_hostname = equinix_network_device.multi-cloud-router.hostname
      ne_asn = var.network_edge_asn
      clouds = var.clouds
    }
  )
}

resource "local_file" "group_vars" {
  filename = "./ansible/inventory/group_vars/routers.yml"
  content = templatefile(
    "./locals/group_vars.tftpl",
    {
      ssh_user = var.ssh_user
      ssh_password = var.ssh_password
    }
  )
}

resource "local_file" "ansible_hosts" {
  filename = "./ansible/inventory/hosts"
  content = templatefile(
    "./locals/hosts.tftpl",
    {
      ne_ip = equinix_network_device.multi-cloud-router.ssh_ip_address
    }
  )
}

resource "null_resource" "exec_ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook build_cfg.yml -vvvv"
    working_dir = "${path.module}/ansible"
  }
  depends_on = [ 
    equinix_network_device.multi-cloud-router
  ]
}
