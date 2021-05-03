
## Install MISP 

sudo useradd -s /bin/bash -m -G adm,cdrom,sudo,dip,plugdev,www-data,staff misp


wget -O INSTALL.sh https://raw.githubusercontent.com/MISP/MISP/2.4/INSTALL/INSTALL.sh


chmod +x INSTALL.sh

./INSTALL.sh -c -M -u


## Install The Hive + cortex 

sudo apt-get install apt-transport-https

echo 'deb https://dl.bintray.com/thehive-project/debian-beta any main' | sudo tee -a /etc/apt/sources.list.d/thehive-project.list


echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list


wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

curl https://raw.githubusercontent.com/TheHive-Project/TheHive/master/PGP-PUBLIC-KEY | sudo apt-key add -

sudo apt-get update -y 

sudo apt-get install openjdk-8-jre -y 

sudo apt-get install elasticsearch -y

sudo echo "cluster.name: hive" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "bootstrap.memory_lock: true" >> /etc/elasticsearch/elasticsearch.yml
sudo echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml

sudo systemctl daemon-reload

sudo systemctl enable elasticsearch

sudo systemctl start elasticsearch

sudo apt-get install thehive -y

sudo apt-mark hold elasticsearch thehive

sudo apt-get install cortex -y 

sudo apt-mark hold cortex


sudo apt-get install -y --no-install-recommends python-pip python2.7-dev python3-pip python3-dev ssdeep libfuzzy-dev libfuzzy2 libimage-exiftool-perl libmagic1 build-essential git libssl-dev

sudo pip install -U pip setuptools && sudo pip3 install -U pip setuptools

cd /etc/cortex; sudo git clone https://github.com/TheHive-Project/Cortex-Analyzers

cd /etc/cortex; sudo chown -R root:cortex Cortex-Analyzers

cd /etc/cortex ; for I in $(find Cortex-Analyzers -name 'requirements.txt'); do sudo -H pip2 install -r $I; done && \
for I in $(find Cortex-Analyzers -name 'requirements.txt'); do sudo -H pip3 install -r $I || true; done

