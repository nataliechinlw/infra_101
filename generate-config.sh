#!/usr/bin/env bash

rm -rf /apps/jar
mkdir /apps/jar

echo "app.greeting=$1!
app.title=$2" > /apps/jar/hello-spring-boot.properties
