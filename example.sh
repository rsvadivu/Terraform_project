#!/bin/bash
sudo echo "Apache Installation.."

sudo apt-get update
sudo apt-get install apache2 -y

sudo echo "Installing GIT"
sudo apt-get git

sudo "Cloning and coping files from GIT Hub"
sudo git clone https://github.com/amolshete/card-website.git
cp -rf card-webiste/* /var/www/html

