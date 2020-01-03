#!/usr/bin/env bash

apt-get update

apt-get install default-jre -y

rm -rf /vagrant/jar
wget --no-check-certificate --content-disposition https://github.com/Thoughtworks-SEA-Capability/Infrastructure-101-Pathway/blob/master/week1/hello-spring-boot-0.1.0.jar?raw=true -P /vagrant/jar
nohup java -jar /vagrant/jar/hello-spring-boot-0.1.0.jar &
