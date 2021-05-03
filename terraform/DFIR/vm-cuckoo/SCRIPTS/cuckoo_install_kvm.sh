#!/bin/bash

function getValue(){
        cat $ENVFILE | grep "^$1=" | cut -d "=" -f 2 | head -n 1 | tr -d "\n"
}

function param(){
        CONF_HYPERVISOR=/home/cuckoo/.cuckoo/conf/$CUCKOO_HYPERVISOR.conf
        $PREFIX perl -p -i -e "s/(?<=label =).+/ $CUCKOO_GUEST_VMNAME/g" $CONF_HYPERVISOR
        $PREFIX perl -p -i -e "s/(?<=^ip =).+/ $CUCKOO_GUEST_IP/g" $CONF_HYPERVISOR
        $PREFIX perl -p -i -e "s/(?<=snapshot =).+/ $CUCKOO_GUEST_SNAPSHOT/g" $CONF_HYPERVISOR


        CONF_CUCKOO=/home/cuckoo/.cuckoo/conf/cuckoo.conf
        $PREFIX perl -p -i -e "s/(?<=^version_check =).+/ no/g" $CONF_CUCKOO
        $PREFIX perl -p -i -e "s/(?<=^ip =).+/ $CUCKOO_RESULTSERVER_IP/g" $CONF_CUCKOO
        $PREFIX perl -p -i -e "s/(?<=ignore_vulnerabilities =).+/ yes/g" $CONF_CUCKOO
        $PREFIX perl -p -i -e "s/(?<=machinery =).+/ $CUCKOO_HYPERVISOR/g" $CONF_CUCKOO
        $PREFIX perl -p -i -e "s/(?<=connection =).+/ $CUCKOO_DATABASE/g" $CONF_CUCKOO
		
		$PREFIX chown cuckoo: $CONF_CUCKOO $CONF_HYPERVISOR
}

INIT_PATH=$HOME/cuckoo

# Vérification de la présence de quelques variables indispensables à la configuration de cuckoo.
ENVFILE=`dirname $0`/envfile
test -f "$ENVFILE"
if [ $? -ne 0 ];then
        # If envfile doesn't exist, create it and exit. User must fill it properly and re-run installation
        cat > "$ENVFILE" << EOF
CUCKOO_HYPERVISOR=kvm
CUCKOO_GUEST_VMNAME=win10
CUCKOO_GUEST_IP=192.168.122.110
CUCKOO_GUEST_SNAPSHOT=CUCKOO_READY
CUCKOO_RESULTSERVER_IP=0.0.0.0
CUCKOO_DATABASE=postgresql://cuckoo:Analyste@127.0.0.1:5432/cuckoo
EOF
        echo "$ENVFILE has been created, fill it properly and re-run installation."
        exit 1
fi


CUCKOO_HYPERVISOR=$(getValue CUCKOO_HYPERVISOR)
CUCKOO_GUEST_VMNAME=$(getValue CUCKOO_GUEST_VMNAME)
CUCKOO_GUEST_IP=$(getValue CUCKOO_GUEST_IP)
CUCKOO_GUEST_SNAPSHOT=$(getValue CUCKOO_GUEST_SNAPSHOT)
CUCKOO_RESULTSERVER_IP=$(getValue CUCKOO_RESULTSERVER_IP)
CUCKOO_DATABASE=$(getValue CUCKOO_DATABASE)

# On commence par vérifier l'utilisateur courant, si c'est root alors pas besoin d'utiliser la commande sudo pour les commandes spécifiques
PREFIX=""

if [ $USER != "root" ];then
        # On vérifie si sudo est installé
        which sudo > /dev/null
        if [ $? -ne 0 ];then
                echo "sudo does not seem to be installed, to execute this script as non-root user you must install sudo, or run it as 'root'..."
                exit 1
        fi

        # On part du principe que si sudo est installé et que l'on est connecté en tant que simple utilisateur, le fichier /etc/sudoers a déjà été configuré pour que cet
        # utilisateur puisse utiliser sudo sans password (type box vagrant)

        PREFIX="sudo "

fi

$PREFIX useradd -m cuckoo --shell /bin/bash
echo "cuckoo ALL=(ALL) NOPASSWD: ALL" | $PREFIX tee -a /etc/sudoers
echo "cuckoo:cuckoo" | $PREFIX chpasswd


$PREFIX apt update && $PREFIX apt install -y \
        gnupg2 \
        $PREFIX \
        unzip \
        wget

# Ajout du repository mongodb
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | $PREFIX apt-key add -
echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/4.2 main" | $PREFIX tee /etc/apt/sources.list.d/mongodb.list

# Installation des paquets nécessaires
$PREFIX apt update && $PREFIX apt install -y \
    apparmor-utils \
    automake \
    bison \
    bridge-utils \
    cpu-checker \
    curl \
    flex \
    gcc \
    git \
    libcap2-bin \
    libffi-dev \
    libfuzzy-dev \
    libjansson-dev \
    libjpeg-dev \
    libmagic-dev \
    libssl-dev \
    libtool \
    libvirt0 \
    libvirt-dev \
    make \
    mongodb-org \
    python \
    python-dev \
    python-libvirt \
    python-pip \
    python-setuptools \
    python-ssdeep \
    python-virtualenv \
    qemu-kvm \
    ssdeep \
    swig \
    tcpdump \
    unzip \
    virtinst \
    virt-manager \
    postgresql \
    postgresql-contrib \
    postgresql-server-dev-all \
    zlib1g-dev

## Configuration KVM
if [ $CUCKOO_HYPERVISOR = "kvm" ];then
$PREFIX virsh net-autostart default
$PREFIX virsh net-start default
CUCKOO_RESULTSERVER_IP=`$PREFIX ifconfig virbr0 | grep netmask | awk -F " " '{print $2}'`
fi

$PREFIX aa-disable /usr/sbin/tcpdump
$PREFIX setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
$PREFIX getcap /usr/sbin/tcpdump

$PREFIX usermod -a -G kvm cuckoo
$PREFIX usermod -a -G libvirt cuckoo
$PREFIX usermod -a -G libvirt-qemu cuckoo


# Installation de YARA
cd /tmp/
wget https://github.com/VirusTotal/yara/archive/v3.11.0.zip
unzip -o v3.11.0.zip
cd yara-3.11.0
./bootstrap.sh
./configure --enable-cuckoo --enable-magic --enable-dotnet
make
$PREFIX make install
echo "========="
make check
cd $OLDPWD

$PREFIX pip install \
    pip \
    pydeep \
    "weasyprint==0.39" \
    yara-python

$PREFIX systemctl enable mongod
$PREFIX systemctl start mongod


############### Validé jusqu'ici


# ===================
# CUCKOO INSTALLATION
# ===================

$PREFIX chmod 705 /opt/
$PREFIX mkdir /opt/cuckoo 2>/dev/null
$PREFIX chown -R cuckoo: /opt/cuckoo
sudo -u cuckoo -- sh -c '
cd /opt/
virtualenv cuckoo
. cuckoo/bin/activate
pip install -U pip setuptools
pip install -U cuckoo
pip install -U distorm3
pip install -U libvirt-python==5.0
pip install -U yara-python
pip install -U psycopg2
pip install -U weasyprint==0.39
echo "================== debug 1 ============"
echo "----> cuckoo -d"
cuckoo -d
'

echo "----> cuckoo community"
sudo -u cuckoo -- sh -c '
cd /opt/; virtualenv cuckoo 
. cuckoo/bin/activate
cuckoo community
'

sudo -u cuckoo -- sh -c '
cd /opt/; virtualenv cuckoo 
. cuckoo/bin/activate
pip install git+https://github.com/volatilityfoundation/volatility.git
'

sudo -u postgres -- sh -c "
psql << EOF
        CREATE DATABASE cuckoo;
        CREATE USER cuckoo WITH ENCRYPTED PASSWORD 'Analyste';
        GRANT ALL PRIVILEGES ON DATABASE cuckoo TO cuckoo;
        \q
EOF
"

# Création des règles Firewall
$PREFIX iptables -t nat -A POSTROUTING -o virbr0 -s 192.168.122.0/24 -j MASQUERADE
$PREFIX iptables -P FORWARD DROP
$PREFIX iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
$PREFIX iptables -A FORWARD -s 192.168.122.0/24 -j ACCEPT
$PREFIX iptables -A FORWARD -s 192.168.122.0/24 -d 192.168.122.0/24 -j ACCEPT
$PREFIX iptables -A FORWARD -j log --log-prefix='[cuckoo]'

### Persistence des règles
#$PREFIX iptables-save > /etc/iptables/rules.v4

echo 1 | $PREFIX tee -a /proc/sys/net/ipv4/ip_forward
$PREFIX sysctl -w net.ipv4.ip_forward=1

# Création des scripts de démarrage

SYSTEMD="/lib/systemd/system"

$PREFIX cp $INIT_PATH/CONF/systemd/cuckoo.service $SYSTEMD
$PREFIX cp $INIT_PATH/CONF/systemd/cuckooweb.service $SYSTEMD

$PREFIX perl -p -i -e "s/(?<=^User=).+/ cuckoo/g" $SYSTEMD/cuckoo.service
$PREFIX perl -p -i -e "s/(?<=^Group=).+/ cuckoo/g" $SYSTEMD/cuckoo.service

$PREFIX perl -p -i -e "s/(?<=^User=).+/ cuckoo/g" $SYSTEMD/cuckooweb.service
$PREFIX perl -p -i -e "s/(?<=^Group=).+/ cuckoo/g" $SYSTEMD/cuckooweb.service

$PREFIX cp $INIT_PATH/SCRIPTS/cuckoo.sh /opt/
$PREFIX cp $INIT_PATH/SCRIPTS/cuckooweb.sh /opt/
$PREFIX chown cuckoo: /opt/cuckoo.sh
$PREFIX chown cuckoo: /opt/cuckooweb.sh

# Exécution de cuckoo et cuckooweb au démarrage du système et lancement
$PREFIX systemctl daemon-reload
$PREFIX systemctl enable cuckoo --now 
$PREFIX systemctl enable cuckooweb 

echo "=====  Temporisation démarage du server, et création de fichier  ====="
sleep 30
echo "=====  Fin  ====="

$PREFIX cp -f $INIT_PATH/CONF/Cuckoo/* /home/cuckoo/.cuckoo/conf/
$PREFIX chown -R cuckoo:cuckoo /home/cuckoo/.cuckoo

param
