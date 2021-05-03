#!/bin/bash

# Variables
TRASHDIR=/tmp/trashdir/

echo "Création du trashdir"
mkdir $TRASHDIR

echo "Installation de Terraform"
pacman -S --noconfirm terraform

echo "Installation de Packer"
pacman -S --noconfirm packer

echo "Installation de Base-devel"
pacman -S --noconfirm base-devel

echo "Installation de Ansible"
pacman -S --noconfirm ansible 

echo "Téléchargement du bundle OVFTOOL"
wget https://srv-store5.gofile.io/download/4Q9h3T/VMware-ovftool-4.4.1-16812187-lin.x86_64.bundle $TRASHDIR

echo "Exécution du bundle OVFTOOL"
chmod +x VMware-ovftool-4.4.1-16812187-lin.x86_64.bundle
sh ./VMware-ovftool-4.4.1-16812187-lin.x86_64.bundle

