# Deploiement de Cuckoo Via terraform et Packer

## Sommaire

- [Préparation de l'host](#preparation-de-l-host)
- [Déploiement](#déploiement)
- [Fin Manuelle](#fin-manuelle)

### Préparation de l'host

Pour le déploiement de la Vm cuckoo il sera nécessaire de savoir sur quel Os nous voulons partir. De notre côté nous avons choisi un vm Windows 10. La création de la vm a été faite avec l’outil packer qui va venir suivre les instructions spécifier dans le fichier `.xml`

```
.
├── Autounattend.xml
├── build.log
├── build.sh
├── drivers
│   └── virtio-win.iso
├── files
│   ├── cuckoo_agent.py
│   ├── secubian-vmware-share-automount
│   └── winlogbeat-sandbox.yml
├── scripts
│   ├── chocolatey.ps1
│   ├── disable-screensaver.ps1
│   ├── disable-windowsDefender.bat
│   ├── disable-windows-update.ps1
│   ├── disable-winrm.ps1
│   ├── enable-winrm.ps1
│   ├── fixnetwork.ps1
│   ├── install-FTKImager.ps1
│   ├── install-zimmermantools.ps1
│   ├── microsoft-updates.bat
│   ├── Readme.md
│   ├── rearm-windows.ps1
│   ├── Set-SysmonSettings.ps1
│   ├── Set-WindowsTelemetrySettings.ps1
│   ├── vmware-tools.ps1
│   └── win-updates.ps1
├── win10.json
└── windows10-enterprise.iso
```

La création de la vm peut prendre un certain temps, suivant la machine sur laquel nous travaillons ainsi que la connexion internet. Il faut environ compter 20 ~ 30 pour une installation. 

```bash
export PACKER_LOG=1; packer build win10.json | tee build.log
```

Tous les fichiers présents dans le répertoire `scripts` vont être ajoutés à la vm et exécuté pour être implanté à la vm.

Pour le déploiement il est préférable d’avoir l’image sur une machine dans le même réseau, ainsi là l’envoie sur la vm sera plus rapide. Si vous souhaitez la provisioner avec terrform il faut faire attention à avoir l’espace dans le dossier `/tmp/`. Dans notre cas nous avons généré une clef RSA, pour passer par `scp`.

### Déploiement 

Pour le déploiement il suffit de faire un `terraform apply -auto-approve`. Normalement tout va se dérouler automatiquement.

```
./
├── CONF
│   ├── Cuckoo
│   │   ├── auxiliary.conf
│   │   ├── kvm.conf
│   │   └── reporting.conf
│   ├── id_rsa
│   ├── id_rsa.pub
│   └── systemd
│       ├── cuckoo.service
│       └── cuckooweb.service
├── main.tf
├── output.tf
├── README.md
├── SCRIPTS
│   ├── cuckoo_install_kvm.sh
│   ├── cuckoo.sh
│   ├── cuckooweb.sh
│   └── cuckoo-win10.sh
├── variables.tf
└── versions.tf
```

### Fin Manuelle

Une fois le déploiement automatique terminé, la vm devrait s'éteindre tout seul une fois terminé il faut aller dans les options de la vm à traver le provider ( ESXI pour nous ) :

![Vgpu](https://pic.l42.fr/eSWKgavg.png)

Ainsi nous activerons la nested virtu à travers cette vm. Il ne nous reste plus que à rallumer la vm et lancer cette ligne de commande : 

```bash
sudo bash ./cuckoo-win10.sh
```

Ainsi nous ajouterons la vm Windows 10 au libvirt interne à la machine.  Grâce à la manipulation précédente nous pourrons la lancer sans soucis.
