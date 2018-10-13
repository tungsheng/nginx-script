#!/bin/bash

# Variables
availableDIR="/etc/nginx/sites-available"

# Functions
get_domain() {
  echo -e "\n\n"
  read -e -p "Enter a domain (e.g. domain.com) " -r domain
  if [ ! -f  "$availableDIR/${#domain}" ]; then
    echo " >> Domain does not exist!"
    echo " >> Please try again."
    get_domain
  fi
  echo -e "\n\n"
}

# Install dependencies
sudo add-apt-repository "deb http://ftp.debian.org/debian stretch-backports main contrib non-free"
sudo add-apt-repository "deb-src http://ftp.debian.org/debian stretch-backports main contrib non-free"
sudo apt update

# Install certbot
sudo apt install -y python-certbot-nginx -t stretch-backports

# Firewall allows https
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'

# Setup
sudo certbot -d $domain

# You can check renewal works using:
# sudo certbot renew --dry-run

# You can also check what certificates exist using:
# sudo certbot certificates

# http/2
# change:
# listen [::]:443 ssl ipv6only=on;
# listen 443 ssl;

# to:
# listen [::]:443 ssl http2 ipv6only=on;
# listen 443 ssl http2;
# gzip off;
