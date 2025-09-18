#!/bin/bash
port=$1;
name=$2;
docker_name=$3;
sudo docker run -it \
-v /Users/hieunguyen:/home/hieunguyen \
-v /Volumes:/media \
-p ${port}:8787 -e PASSWORD=genov4 --name ${name} ${docker_name}