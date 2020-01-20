FROM ubuntu:latest

WORKDIR /usr/src/app
RUN apt-get update
RUN apt-get install -y wget
RUN wget --no-check-certificate --content-disposition https://github.com/Thoughtworks-SEA-Capability/Infrastructure-101-Pathway/blob/master/week1/hello-spring-boot-0.1.0.jar?raw=true -P .
RUN apt-get update
RUN apt-get install -y openjdk-11-jre-headless
EXPOSE 8080

CMD java -jar hello-spring-boot-0.1.0.jar