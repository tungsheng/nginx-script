#!/bin/bash

# Variables
version=1.15.5

# Install dependancies
sudo apt update
sudo apt install -y \
  build-essential \
  libpcre3 \
  libpcre3-dev \
  libssl-dev \
  ufw \
  zlib1g \
  zlib1g-dev

# Download source
sudo wget http://nginx.org/download/nginx-${version}.tar.gz
sudo tar -zxvf nginx-${version}.tar.gz
cd nginx-${version}/

# Compile source
sudo ./configure \
  --without-http_autoindex_module \
  --sbin-path=/usr/bin/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx.pid \
  --with-pcre \
  --with-http_ssl_module \
  --with-http_v2_module

# Install source
sudo make
sudo make install

# Firewall allows nginx http
nginxHTTP=/etc/ufw/applications.d/nginx-http
nginxHTTPS=/etc/ufw/applications.d/nginx-https
nginxFULL=/etc/ufw/applications.d/nginx-full
sudo touch nginxHTTP
sudo touch nginxHTTPS
sudo touch nginxFULL
sudo cat <<EOT > $nginxHTTP
[Nginx HTTP]
title=Web Server (HTTP)
description=for serving web
ports=80/tcp
EOT
sudo cat <<EOT > $nginxHTTPS
[Nginx HTTPS]
title=Web Server (HTTPS)
description=for serving web
ports=443/tcp
EOT
sudo cat <<EOT > $nginxFULL
[Nginx Full]
title=Web Server (HTTP and HTTPS)
description=for serving web
ports=80,443/tcp
EOT
sudo ufw allow 'Nginx HTTP'

# Update nginx.conf
sudo cp -f $HOME/nginx-script/nginx.example.conf /etc/nginx/nginx.conf

# Add site
source $HOME/nginx-script/addsite.sh

# Add Nginx service
echo -ne "Adding Nginx service...\n"
nginxService=/lib/systemd/system/nginx.service
[ -f $nginxService ] || touch $nginxService
cat <<EOT > $nginxService
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/bin/nginx -t
ExecStart=/usr/bin/nginx
ExecReload=/usr/bin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOT

echo -ne "Check Nginx syntax...\n"
nginx -t

echo -ne "Enabling Nginx...\n"
sudo systemctl enable nginx

echo -ne "Starting Nginx...\n"
sudo systemctl start nginx

exit 0
