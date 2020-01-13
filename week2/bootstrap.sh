#! /bin/bash

sudo apt-get update
sudo apt-get install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install --yes ansible
sudo apt-get install -y default-jre

groupadd -r appmgr
useradd -r -s /bin/nologin -g appmgr jarapps

mkdir apps/jar
wget --no-check-certificate --content-disposition https://github.com/Thoughtworks-SEA-Capability/Infrastructure-101-Pathway/blob/master/week1/hello-spring-boot-0.1.0.jar?raw=true -P /apps/jar

echo "[Unit]
Description=Run hello-spring-boot jar

[Service]
WorkingDirectory=/apps/jar
ExecStart=/usr/bin/java -Xms128m -Xmx256m -jar hello-spring-boot-0.1.0.jar
User=jarapps
Type=simple
Restart=on-failure
RestartSec=10" > /etc/systemd/system/hello-spring-boot.service

chown -R jarapps:appmgr /apps/jar
systemctl daemon-reload
systemctl start hello-spring-boot.service