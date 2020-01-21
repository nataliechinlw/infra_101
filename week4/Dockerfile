FROM ubuntu:latest

WORKDIR /usr/src/app
RUN apt-get update
ADD https://github.com/Thoughtworks-SEA-Capability/Infrastructure-101-Pathway/blob/master/week1/hello-spring-boot-0.1.0.jar?raw=true .
RUN apt-get install -y openjdk-8-jre-headless
RUN apt-get install -y openjdk-11-jre-headless
ENV JAVA_VERSION 11
EXPOSE 8080

CMD /usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64/bin/java -jar hello-spring-boot-0.1.0.jar