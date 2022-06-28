#!/bin/bash
#wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
#echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
#apt-get install -y apt-transport-https ca-certificates
sudo cp /tmp/mongodb.service /etc/systemd/system/
apt-get update
chown 777 /etc/systemd/system/mongodb.service
apt install -y mongodb
systemctl start mongodb
systemctl enable mongodb
