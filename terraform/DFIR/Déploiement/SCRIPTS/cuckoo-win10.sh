#!/bin/bash

echo 3 | sudo tee /proc/sys/vm/drop_caches 1>/dev/null

## Enregistrement de la machine virtuelle win10
sudo virt-install --import --name win10 --memory 2048 --vcpus 2 --cpu host --accelerate --virt-type kvm --hvm --os-type windows --os-variant win10 --disk /var/lib/libvirt/images/Win10.qcow2,format=qcow2,bus=virtio --network bridge=virbr0,model=virtio --noautoconsole

## Attribution d'une addresse ipv4 statique
sleep 180
sudo virsh net-update default delete ip-dhcp-range "`sudo virsh net-dumpxml default | grep 'range' | sed 's/      //'`" --live --config
sudo virsh destroy win10
sudo virsh net-update default add-last ip-dhcp-host "<host mac='`sudo virsh dumpxml win10 | grep -i 'mac address' | awk -F "'" '{print $2}'`' name='win10' ip='192.168.122.110'/>" --live --config

## Création du snapshot nécessaire à cuckoo
sudo virsh start win10
sleep 900
sudo virsh snapshot-create-as --domain win10 --name CUCKOO_READY
sudo virsh destroy win10

## Création du template d'index cukoo dans ELK
curl -u "elastic:Analyste" -H 'Content-Type: application/json' -XPUT http://10.10.12.35:9201/_template/cuckoo_template -d '{"index_patterns":["cuckoo"],"template":{"mappings":{"_doc":{"_meta":{},"_source":{},"properties":{}}}}}'

sudo reboot
