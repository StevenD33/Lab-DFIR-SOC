#########################################
#  ESXI Provider host/login details
#########################################

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_hostport = var.esxi_hostport
  esxi_hostssl  = var.esxi_hostssl
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

#########################################
#  ESXI Guest resource
#########################################

resource "esxi_guest" "resultat_analyse" {
  guest_name = "resultat_analyse"
  disk_store = "datastore1"
  guestos    = "ubuntu-64"

  boot_disk_type = "thin"
  boot_disk_size = "15"

    memsize            = "8192"
  numvcpus           = "4"
  resource_pool_name = "/"
  power              = "on"

  clone_from_vm = "ubuntu_1804_template"


  network_interfaces {
    virtual_network = "Vswitch-Infinity"
  }

  guest_startup_timeout  = 600
  guest_shutdown_timeout = 30

  connection {
      type = "ssh"
      host = self.ip_address
      user = "analyste"
      password = "Analyste"
      timeout = "280s"
  }
      provisioner "remote-exec" {
      inline = [
          "sudo apt update -y"
      ]
  }
      provisioner "remote-exec" {
      inline = [
          "sudo apt upgrade -y"
      ]

  }


}
