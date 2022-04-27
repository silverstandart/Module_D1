#!/bin/sh
# ---------------------------------------------------------------------------------------
#   Test Remove all Containers and Images / 2022_04_22 / ANa
# ---------------------------------------------------------------------------------------

echo ------------------------------------------------------ Remove all Image and stuff

sudo chown -R andrey:sudo microservices_root

sudo docker ps
sudo docker stack rm andrey
sudo docker rm -v -f $(sudo docker ps -qa)
sudo docker image rm -f $(sudo docker image ls -qa)
sudo docker volume rm $(sudo docker volume ls -q)

rm -rf microservices_root

