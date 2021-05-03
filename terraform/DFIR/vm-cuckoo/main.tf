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

resource "esxi_guest" "sandbox_cuckoo" {
  guest_name = "sandbox_cuckoo"
  disk_store = "datastore1"
  guestos    = "ubuntu-64"

  boot_disk_type = "thin"
  boot_disk_size = "50"

  memsize            = "6144"
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
      "sudo apt update -y",
      "sudo apt upgrade -y"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Sandbox' | sudo tee /etc/hostname",
      "sudo apt update -y; sudo apt install -y git-core cifs-utils",
      "sudo sed -i 's/#Pubkey/Pubkey/g' /etc/ssh/sshd_config",
      "mkdir /home/analyste/.ssh",
      "sudo systemctl restart sshd ",
      "mkdir -p /home/analyste/cuckoo/CONF; mkdir /home/analyste/cuckoo/SCRIPTS"
    ]
  }

  provisioner "file" {
    source = "./CONF/"
    destination = "$HOME/cuckoo/CONF/"
  }

  provisioner "file" {
    source = "./SCRIPTS/"
    destination = "$HOME/cuckoo/SCRIPTS/"
  }

  provisioner "remote-exec" {
    inline = [
      "mv $HOME/cuckoo/CONF/id_rsa.pub $HOME/.ssh/authorized_keys",
      "chmod 644 $HOME/.ssh/authorized_keys",
      "chmod +x $HOME/cuckoo/SCRIPTS/cuckoo-win10.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo -u analyste -- sh -c 'cd /home/analyste/cuckoo/SCRIPTS/; chmod +x cuckoo_install_kvm.sh; ./cuckoo_install_kvm.sh; ./cuckoo_install_kvm.sh'"
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ./CONF/id_rsa ./VM/Win10.qcow2 analyste@${self.ip_address}:./"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv $HOME/Win10.qcow2 /var/lib/libvirt/images",
      "sudo systemctl poweroff -i"
    ]
  }
}
