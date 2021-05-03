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

resource "esxi_guest" "Sift-workstation" {
  guest_name = "Sift-workstation"
  disk_store = "datastore1"
  guestos    = "ubuntu-64"

  boot_disk_type = "thin"

  memsize            = "6144"
  numvcpus           = "6"
  resource_pool_name = "/"
  power              = "on"
  ovf_source         = "./Sift-workstation.ova"


  network_interfaces {
    virtual_network = "Vswitch-Infinity"
  }

  guest_startup_timeout  = 600
  guest_shutdown_timeout = 30

  connection {
      type = "ssh"
      host = self.ip_address
      user = "sansforensics"       
      password = "forensics"
      timeout = "280s"
  }  
      provisioner "file" {
        source = "./scripts/install_tools.sh"
        destination = "/tmp/install_tools.sh"
    }
              
      provisioner "remote-exec" {
      inline = [         
          "sudo rm -rf /etc/apt/sources.list.d/saltstack.list",
          "sudo rm -rf /etc/samba/smb.conf",
          "sudo apt update -y",
          "sudo apt upgrade -y",
          "wget https://REMnux.org/remnux-cli",
          "mv remnux-cli remnux",
          "chmod +x remnux",
          "sudo mv remnux /usr/local/bin",
          "sudo remnux install --mode=addon",
          "sudo remnux install --mode=addon",
          "sudo chmod +x /tmp/install_tools.sh",
          "sudo bash /tmp/install_tools.sh"
      ]
  }



}
