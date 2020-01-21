#! /bin/bash

sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt install -y docker.io
sudo docker pull nataliechin/hello-spring-boot:1.0
sudo docker run --publish 8080:8080 --detach --name hello-spring-boot nataliechin/hello-spring-boot:1.0