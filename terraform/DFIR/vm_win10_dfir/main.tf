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
      source = "./script1.ps1"
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
      source = "./bg.ps1"
      destination = "C:/Users/analyste/Pictures/bg.ps1"
  }

    provisioner "remote-exec" {
    inline = [
       "powershell.exe C:/Users/analyste/Pictures/bg.ps1"
    ]
  }
}

