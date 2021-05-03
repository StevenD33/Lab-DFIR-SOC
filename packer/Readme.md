# Packer 

Packer est une solution développée par HashiCorp disponible gratuitement.
Son rôle est de faciliter la génération de machines virtuelles à travers des fichiers de configuration "virtualmachineAScode".

Packer a un rôle important au sein de mon projet PIN "Plateforme d'Investigation Numérique".
Il me permet d'élaborer, au format OVA, les templates des machines constituant l'analyse en SandBox, et celles dédiées à l'utilisation d'outils spécifiques.

Ces templates seront ensuite déployés grâce à Terraform.
Les configurations appliquées à Terraform permettront l'installation de nouveaux outils, notamment grâce à Chocolatey.

## Installation

L'installation s'effectue très facilement sur une grande majorité des systèmes d'exploitation.
Le binaire est téléchargeable ici : https://www.packer.io/downloads

Une fois téléchargé, le binaire devra être placé dans un répertoire du PATH pour pouvoir l'exécuter.



## Pré-requis

Certains pré-requis sont nécessaires à l'utilisation de PACKER.
Dans un premier temps, activez le service SSH sur l'hyperviseur. Puis une fois connecté, exécutez la commande suivante pour que Packer puisse interagir avec les machines virtuelles.

```
esxcli system settings advanced set -o /Net/GuestIPHack -i 1
```

