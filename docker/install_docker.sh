#!/bin/bash

set -eEuo pipefail
set -x

script_dir="${1}"

sudo apt-get update
sudo apt-get install -y software-properties-common
sh -c 'curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -'
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt-get update
sudo apt-get install -y --no-install-recommends docker-ce
mkdir -p /home/$USER/.docker

sudo cp $script_dir/files_on_node/config.json /home/$USER/.docker/
sudo cp $script_dir/files_on_node/daemon.json /etc/docker/
sudo adduser $USER docker
sudo chmod 666 /var/run/docker.sock

