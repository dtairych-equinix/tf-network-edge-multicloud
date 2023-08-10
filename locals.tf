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

resource "local_file" "ios_restconf" {
  filename = "enable_restconf.exp"
  content = templatefile(
    "./enable_restconf.tftpl",
    {
      ssh_user = var.ssh_user
      ssh_password = var.ssh_password
      ne_ip = equinix_network_device.multi-cloud-router.ssh_ip_address
      hostname = equinix_network_device.multi-cloud-router.hostname
    }
  )
}

resource "null_resource" "exec_restconf" {
  provisioner "local-exec" {
    command = "expect enable_restconf.exp"
    # interpreter = [ "/usr/bin/expect", "-f" ]
    # interpreter = [ "/bin/sh"]
    working_dir = "${path.module}"
  }
  depends_on = [ 
    local_file.ios_restconf,
    equinix_network_device.multi-cloud-router
  ]
}