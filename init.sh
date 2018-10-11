#!/bin/bash

# Variables
version=1.15.5

# Install dependancies
apt-get update
apt-get install -y \
  build-essential \
  libpcre3 \
  libpcre3-dev \
  libssl-dev \
  ufw \
  zlib1g \
  zlib1g-dev

# Download source
wget http://nginx.org/download/nginx-${version}.tar.gz
tar -zxvf nginx-${version}.tar.gz
cd nginx-${version}/

# Compile source
./configure \
  --without-http_autoindex_module \
  --sbin-path=/usr/bin/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --with-pcre --with-http_ssl_module \
  --with-http_v2_module

# Install source
make
make install

# Firewall allows nginx http
nginxHTTP=/etc/ufw/applications.d/nginx-http
nginxHTTPS=/etc/ufw/applications.d/nginx-https
nginxFULL=/etc/ufw/applications.d/nginx-full
touch nginxHTTP
touch nginxHTTPS
touch nginxFULL
cat <<EOT > $nginxHTTP
[Nginx HTTP]
title=Web Server (HTTP)
description=for serving web
ports=80/tcp
EOT
cat <<EOT > $nginxHTTPS
[Nginx HTTPS]
title=Web Server (HTTPS)
description=for serving web
ports=443/tcp
EOT
cat <<EOT > $nginxHTTPS
[Nginx Full]
title=Web Server (HTTP and HTTPS)
description=for serving web
ports=80,443/tcp
EOT
sudo ufw allow 'Nginx HTTP'

# Update nginx.conf
cp -f $HOME/nginx-script/nginx.example.conf /etc/nginx/nginx.conf

# Add Nginx service
echo -ne "Adding Nginx service...\n"
touch /lib/systemd/system/nginx.service
cat <<EOT > /lib/systemd/system/nginx.service
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/bin/nginx -t
ExecStart=/usr/bin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOT

echo -ne "Enabling Nginx...\n"
systemctl enable nginx

echo -ne "Starting Nginx...\n"
systemctl start nginx

exit 0
