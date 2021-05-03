#########################################
#  ESXI Provider host/login details
########################################
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


resource "esxi_guest" "ubuntu_resultat_analyse" {
  guest_name = "ubuntu_resultat_analyse"
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
    provisioner "file" {
      source = "./SCRIPTS/install-dfir.sh"
      destination = "/home/analyste/install-dfir.sh"
 }

      provisioner "remote-exec" {
      inline = [
          "chmod +x /home/analyste/install-dfir.sh",
          "sudo bash /home/analyste/install-dfir.sh"
      ]

}
}


resource "esxi_guest" "windows10_analyste" {
  guest_name = "windows10_analyste"
  disk_store = "datastore1"
  guestos    = "windows9-64"

  boot_disk_type = "thin"
  boot_disk_size = "40"

  memsize            = "6144"
  numvcpus           = "4"
  resource_pool_name = "/"
  power              = "on"

  clone_from_vm = "template-Win10"


  network_interfaces {
    virtual_network = "Vswitch-Infinity"
  }

  guest_startup_timeout  = 600
  guest_shutdown_timeout = 30

  connection {
      type = "winrm"
      host = self.ip_address
      user = "analyste"       
      password = "analyste"
      timeout = "280s"
  }  
    provisioner "remote-exec" {
    inline = [
        "choco install -y 7zip",
        "choco install -y autopsy",
        "choco install -y ghidra git",
        "choco install -y sleuthkit",
        "choco install -y volatility",
        "choco install -y wireshark",
        "choco install -y jdk8",
        "choco install -y network-miner --ignore-checksums",
        "Set-WinUserLanguageList -LanguageList fr-FR -Force",
        "powershell.exe git clone https://github.com/sans-blue-team/DeepBlueCLI.git C:/Users/analyste/Desktop/DeepBlueCLI",
        "powershell.exe Invoke-WebRequest https://github.com/DFIR-ORC/dfir-orc/releases/download/v10.0.18/DFIR-Orc_x64.exe -OutFile C:/Users/analyste/Desktop/DFIR-Orc_x64.exe",
        "choco install -y javaruntime"
    ]
    }
    provisioner "file" {
      source = "./SCRIPTS/script1.ps1"
      destination = "C:/Users/analyste/Desktop/script1.ps1"
  }
    provisioner "remote-exec" {
    inline = [
        "powershell.exe C:/Users/analyste/Desktop/script1.ps1"

    ]
  }
    provisioner "remote-exec" {
    inline = [
        "powershell.exe Invoke-WebRequest https://i.ibb.co/pKpX7jn/dfirbg.png -OutFile C:/Users/analyste/Pictures/dfirbg.png"

    ]
  }

    provisioner "file" {
      source = "./SCRIPTS/bg.ps1"
      destination = "C:/Users/analyste/Pictures/bg.ps1"
  }

    provisioner "remote-exec" {
    inline = [
       "powershell.exe C:/Users/analyste/Pictures/bg.ps1"
    ]
  }
}

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
resource "esxi_guest" "stockage" {
  guest_name = "stockage"
  disk_store = "datastore1"
  guestos    = "ubuntu-64"

  boot_disk_type = "thin"
  boot_disk_size = "20"

  memsize            = "2048"
  numvcpus           = "2"
  resource_pool_name = "/"
  power              = "on"

  clone_from_vm = "ubuntu_1804_template"


  network_interfaces {
    virtual_network = "Vswitch-Infinity"
  }
  virtual_disks {
      virtual_disk_id = esxi_virtual_disk.dfirlab-storage-disk2.id
          slot            = "0:2"
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
  provisioner "file" {
      source = "./SCRIPTS/memory_autoanalyse.sh"
      destination = "/tmp/memory_autoanalyse.sh"
 }
            
      provisioner "remote-exec" {
      inline = [         
          "echo 'dfirlab-storage' | sudo tee /etc/hostname",
          "echo '127.0.0.1  dfirlab-storage' | sudo tee -a /etc/hosts",
          "sudo apt update && sudo apt upgrade -y",
          "export DEBIAN_FRONTEND=noninteractive; sudo -E bash -c 'apt install -y open-vm-tools htop net-tools ifplugd resolvconf vim samba samba-client'",
          "echo 'alias ll=\"ls -la\" >> $HOME/.bashrc'; echo 'alias ll=\"ls -la\"' | sudo tee -a /root/.bashrc;",
          "echo 'set mouse-=a' > $HOME/.vimrc; echo 'set mouse-=a' | sudo tee /root/.vimrc",
          "echo 'auto eth0' | sudo tee -a /etc/network/interfaces",
          "echo 'iface eth0 inet dhcp' | sudo tee -a /etc/network/interfaces",
          "echo 'pre-up sleep 2' | sudo tee -a /etc/network/interfaces",
          "sudo sed -i -e 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"net.ifnames=0 biosdevname=0\"/g' /etc/default/grub",
          "sudo grub-mkconfig -o /boot/grub/grub.cfg",
          "sudo sed -i -e 's/INTERFACES=.*/INTERFACES=\"eth0\"/g' /etc/default/ifplugd",
          "echo 'dfirlab-storage' | sudo tee /etc/hostname",
          "echo '127.0.0.1  dfirlab-storage' | sudo tee -a /etc/hosts",
          "sudo mkdir /media/evidences",
          "sudo sed -i '25i#socket options = TCP_NODELAY SO_RCVBUF=524288 SO_SNDBUF=524288 IPTOS_LOWDELAY' /etc/samba/smb.conf",
          "sudo sed -i '25isocket options = TCP_NODELAY SO_RCVBUF=524288 SO_SNDBUF=524288 IPTOS_LOWDELAY IPTOS_THROUGHPUT' /etc/samba/smb.conf",
          "sudo sed -i '25ideadtime = 30' /etc/samba/smb.conf",
          "sudo sed -i '25iuse sendfile = yes' /etc/samba/smb.conf",
          "sudo sed -i '25iaio read size = 1' /etc/samba/smb.conf",
          "sudo sed -i '25iaio write size = 1' /etc/samba/smb.conf",
          "sudo sed -i '25i## Tuning' /etc/samba/smb.conf",
          "echo '[evidences]' | sudo tee -a /etc/samba/smb.conf",
          "echo '   comment = upload your evidences on this share' | sudo tee -a /etc/samba/smb.conf",
          "echo '   read only = no' | sudo tee -a /etc/samba/smb.conf",
          "echo '   path = /media/evidences' | sudo tee -a /etc/samba/smb.conf",
          "echo '   guest ok = yes' | sudo tee -a /etc/samba/smb.conf",
          "echo '   writable = yes' | sudo tee -a /etc/samba/smb.conf",
          "echo '   public = yes' | sudo tee -a /etc/samba/smb.conf",
          "echo '   force create mode = 0777' | sudo tee -a /etc/samba/smb.conf",
          "echo '   force user = root' | sudo tee -a /etc/samba/smb.conf",
          "echo -e \"o\nn\np\n1\n\n\nw\" | sudo fdisk /dev/sdb; sudo /usr/sbin/mkfs.ext4 /dev/sdb1",
          "sudo mkdir /media/evidences",
          "echo '/dev/sdb1    /media/evidences  ext4 defaults 0 0'  | sudo tee -a /etc/fstab; sudo mount -a",
          "sudo mkdir /media/evidences/documentation",
          "sudo mkdir /media/evidences/MEMORY",
          "sudo mkdir /media/evidences/HDD",
          "sudo mv /tmp/memory_autoanalyse.sh /media/evidences/MEMORY/; chmod +x /media/evidences/MEMORY/memory_autoanalyse.sh",
          "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/Evidence-of-Poster.pdf",
          "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/Find-Evil-Poster.pdf",
          "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/SANS-DFIR.pdf",
          "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/Smartphone-Forensics-Poster.pdf",
          "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/memory-forensics-cheatsheet.pdf",
          "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/network-forensics-cheatsheet.pdf",
          "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/sift-cheatsheet.pdf",
          "cd /media/evidences/documentation; sudo wget https://raw.githubusercontent.com/teamdfir/sift-saltstack/master/sift/files/sift/resources/windows-to-unix-cheatsheet.pdf",
          "sudo chmod -R 777 /media/evidences"


      ]
  }


}


resource "esxi_virtual_disk" "dfirlab-storage-disk2" {
  virtual_disk_disk_store = var.datastore
  virtual_disk_dir        = "DFIRLab-STORAGE"
  virtual_disk_size       = var.extended-storage_sizes["vm--storage-disk2-evidences"]
  virtual_disk_type       = "thin"
}

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
