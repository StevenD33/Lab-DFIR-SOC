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

resource "esxi_guest" "SIEM" {
  guest_name = "SIEM"
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
    virtual_network = "Vswitch-Infinity2"
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
          "sudo apt upgrade -y",
          "sudo apt install -y git",
      ]
  }
}

resource "esxi_guest" "SIRP" {
  guest_name = "SIRP"
  disk_store = "datastore1"
  guestos    = "ubuntu-64"

  boot_disk_type = "thin"
  boot_disk_size = "45"

  memsize            = "8192"
  numvcpus           = "2"
  resource_pool_name = "/"
  power              = "on"
  clone_from_vm      = "ubuntu_1804_template"


  network_interfaces {
    virtual_network = "Vswitch-Infinity2"
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
      provisioner "file" {
       source = "./SCRIPTS/install_SIRP.sh"
       destination = "/home/analyste/install_SIRP.sh"
  }

     provisioner "remote-exec" {
     inline = [
	 "chmod +x install_SIRP.sh",
	 "./install_SIRP.sh"
     ]
  }
}


resource "esxi_guest" "Threat_Hunting" {
  guest_name = "Threat_Hunting"
  disk_store = "datastore1"
  guestos    = "ubuntu-64"

  boot_disk_type = "thin"
  boot_disk_size = "15"

  memsize            = "4096"
  numvcpus           = "2"
  resource_pool_name = "/"
  power              = "on"

  clone_from_vm = "ubuntu_1804_template"


  network_interfaces {
    virtual_network = "Vswitch-Infinity2"
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
          "sudo apt upgrade -y",
	  "sudo apt install docker.io -y",
	  "sudo apt install curl -y",
	  "sudo apt install docker-compose -y",
	  "git clone https://github.com/Patrowl/PatrowlManager.git /home/analyste/PatrowlManager",
	  "cd /home/analyste/PatrowlManager && sudo docker-compose build --force-rm",
	  "cd /home/analyste/PatrowlManager && sudo docker-compose up -d"
      ]

  }
      provisioner "remote-exec" {
      inline = [
	  "git clone https://github.com/arkime/arkime /home/analyste/arkime",
	  "sudo apt install python3-pip -y",
	  "cd /home/analyste/arkime && sudo bash ./easybutton-build.sh --install"
      ]
  }
      provisioner "remote-exec" {
      inline = [
	  "sudo git clone https://github.com/yeti-platform/yeti.git /home/analyste/yeti",
	  "cd /home/analyste/yeti/extras/docker/dev && sudo docker-compose up -d"
      ]
  }


}
