#!/bin/bash

# Update package list and install prerequisites
sudo apt-get update
sudo apt-get install -y git


for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Clone the other repositories inside the Master directory
git clone https://github.com/yachoo2606/Master_producer.git Producer
git clone https://github.com/yachoo2606/Master-protokol-Worker.git Master-protokol-Worker
git clone https://github.com/yachoo2606/Master-Service-Registry.git Service-registry
git clone https://github.com/yachoo2606/Master-ELK-monitoring.git ELK-monitoring

echo "All repositories cloned and organized successfully!"
echo "Runs Master monitoring and Service registry..."

sudo docker compose --env-file ELK-monitoring/.env down -v && sudo docker compose --env-file ELK-monitoring/.env build --no-cache && sudo docker compose --env-file ELK-monitoring/.env up --force-recreate -d

echo "All done."