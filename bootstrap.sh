#!/usr/bin/env bash

apt-get update

apt-get install default-jre -y

rm -rf /apps/jar
wget --no-check-certificate --content-disposition https://github.com/Thoughtworks-SEA-Capability/Infrastructure-101-Pathway/blob/master/week1/hello-spring-boot-0.1.0.jar?raw=true -P /apps/jar
echo "app.greeting=Hello!
app.title=This is INFRA 101" > /apps/jar/hello-spring-boot.properties

groupadd -r appmgr
useradd -r -s /bin/false -g appmgr jarapps

echo "[Unit]
Description=Run hello-spring-boot jar

[Service]
WorkingDirectory=/apps/jar
ExecStart=/usr/bin/java -Xms128m -Xmx256m -jar hello-spring-boot-0.1.0.jar --spring.config.location=file:/apps/jar/hello-spring-boot.properties
User=jarapps
Type=simple
Restart=on-failure
RestartSec=10" > /etc/systemd/system/hello-spring-boot.service

chown -R jarapps:appmgr /apps/jar
systemctl daemon-reload
systemctl start hello-spring-boot.service
