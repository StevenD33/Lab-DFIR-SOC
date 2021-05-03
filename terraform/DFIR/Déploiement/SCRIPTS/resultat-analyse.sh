#!/bin/bash

echo '-------------------------------'
echo "Installation de gnupg2, apt-transport-https, curl, python3, pip, ca-certificates, lsb-release software-properties-common"
echo '-------------------------------'
sudo apt install -y gnupg2 apt-transport-https curl python3 python3-pip ca-certificates lsb-release software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo '-------------------------------'
echo "Installation de Docker"
echo '-------------------------------'
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo '-------------------------------'
echo "Installation de docker-compose"
echo '-------------------------------'
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.6/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo usermod -aG docker analyste

echo '-------------------------------'
echo "Installation de Timesketch"
echo '-------------------------------'
cd /home/analyste/ && curl -s -O https://raw.githubusercontent.com/google/timesketch/master/contrib/deploy_timesketch.sh
chmod 755 deploy_timesketch.sh
cd /opt && sudo /home/analyste/deploy_timesketch.sh
cd timesketch && sudo docker-compose up -d
rm /home/analyste/deploy_timesketch.sh

echo '-------------------------------'
echo "Création de l'utilisateur Timesketch"
echo '-------------------------------'
sudo docker-compose exec timesketch-web tsctl add_user --username analyste -p Analyste

echo '-------------------------------'
echo "Import de la cle PGP de Elasticsearch"
echo '-------------------------------'
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

echo '-------------------------------'
echo "Enregistrement du repo Elastic"
echo '-------------------------------'
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list

echo '-------------------------------'
echo "Installation de Elasticsearch"
echo '-------------------------------'
sudo apt-get update && sudo apt-get install -y elasticsearch

echo '-------------------------------'
echo "Changement du port par défaut de Elasticsearch"
echo '-------------------------------'

sudo bash -c "echo 'http.port: 9201' >> /etc/elasticsearch/elasticsearch.yml"
sudo bash -c "echo 'transport.host: localhost' >> /etc/elasticsearch/elasticsearch.yml"
sudo bash -c "echo 'transport.tcp.port: 9301' >> /etc/elasticsearch/elasticsearch.yml"
sudo bash -c "echo 'network.host: 0.0.0.0' >> /etc/elasticsearch/elasticsearch.yml"
sudo bash -c "echo 'discovery.type: single-node' >> /etc/elasticsearch/elasticsearch.yml"
sudo bash -c "echo 'xpack.security.enabled: true' >> /etc/elasticsearch/elasticsearch.yml"
sudo bash -c "echo 'xpack.security.transport.ssl.enabled: true' >> /etc/elasticsearch/elasticsearch.yml"
# Necessaire pour eviter : bootstrap check failure [1] of [1]: initial heap size not equal to maximum heap size; this can cause resize pauses
sudo bash -c "echo '-Xms2g' >> /etc/elasticsearch/jvm.options"
sudo bash -c "echo '-Xmx2g' >> /etc/elasticsearch/jvm.options"

echo '-------------------------------'
echo "Demarrage de Elasticsearch au boot"
echo '-------------------------------'
sudo systemctl enable elasticsearch.service

echo '-------------------------------'
echo "Demarrage de Elasticsearch"
echo '-------------------------------'
sudo systemctl start elasticsearch.service

echo '-------------------------------'
echo "Vérification du bon fonctionnement de l'installation"
echo '-------------------------------'
curl -X GET http://localhost:9201/?pretty

echo '-------------------------------'
echo "Installation de Kibana"
echo '-------------------------------'
sudo apt-get install -y kibana

echo '-------------------------------'
echo "Ajout de l'adresse hôte à Kibana"
echo '-------------------------------'
host='"http://0.0.0.0:9201"'
key='"pHUEBX9XGMshJGkzRQTLpDgA6LQuGmc3"'
user='"elastic"'
password='"Analyste"'
sudo bash -c "echo 'server.host: 0.0.0.0' >> /etc/kibana/kibana.yml"
sudo bash -c "echo 'elasticsearch.hosts: [$host]' >> /etc/kibana/kibana.yml"
sudo bash -c "echo 'xpack.reporting.enabled: true' >> /etc/kibana/kibana.yml"
sudo bash -c "echo 'xpack.encryptedSavedObjects.encryptionKey: $key' >> /etc/kibana/kibana.yml"
sudo bash -c "echo 'xpack.security.encryptionKey: $key' >> /etc/kibana/kibana.yml"
sudo bash -c "echo 'xpack.reporting.encryptionKey: $key' >> /etc/kibana/kibana.yml"
sudo bash -c "echo 'elasticsearch.username: $user' >> /etc/kibana/kibana.yml"
sudo bash -c "echo 'elasticsearch.password: $password' >> /etc/kibana/kibana.yml"
                                    
echo '-------------------------------'
echo "Demarrage de Kibana au boot"
echo '-------------------------------'
sudo systemctl enable kibana.service

echo '-------------------------------'
echo "Installation de Filebeat"
echo '-------------------------------'
sudo apt install -y filebeat
sudo filebeat setup
sudo service filebeat start

echo '-------------------------------'
echo "Installation de Suricata"
echo '-------------------------------'
sudo apt install -y suricata jq

echo '-------------------------------'
echo "Demarrage de Suricata au boot"
echo '-------------------------------'
sudo systemctl enable suricata.service

echo '-------------------------------'
echo "Demarrage de Suricata"
echo '-------------------------------'
sudo systemctl start suricata.service

echo '-------------------------------'
echo "Demarrage de Kibana"
echo '-------------------------------'
sudo systemctl start kibana.service

echo '-------------------------------'
echo "Installation de Elastalert"
echo '-------------------------------'
sudo apt install -y elastalert
echo '-------------------------------'
echo "Suppresion des packages qui ne sont plus nécessaires"
echo '-------------------------------'
sudo apt autoremove -y

echo '-------------------------------'
echo "Création du compte Elasticsearch"
echo '-------------------------------'
/usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive

echo '-------------------------------'
echo "Se deconnecter et reconnecter pour appartenir au groupe Docker"
echo '-------------------------------'

