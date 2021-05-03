#!/bin/bash

fdisk /dev/sda <<EEOF
n
p
2


t
2
8e
w
EEOF

pvcreate /dev/sda2
vgextend ubuntu-template-vg /dev/sda2
lvextend /dev/ubuntu-template-vg/root /dev/sda2
resize2fs /dev/ubuntu-template-vg/root
