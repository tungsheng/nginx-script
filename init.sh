#!/bin/bash

function getDomain() {
    echo -e "\n\n"
    read -e -p "Enter a domain (e.g. domain.com) " -r domain
    if [[ "${#domain}" -lt 1 ]]; then
      echo " >> Please enter a valid domain!"
      readDomain
    fi
    echo -e "\n\n"
}

# install nginx
apt-get install -y nginx

# get domain name
getDomain
dir="/var/www/$domain"
if [ -d "$dir" ]; then
  # dir exists.
  rm -rf $dir
fi

mkdir -p $dir

# init www
wwwDIR="/var/www/$domain"
if [ -e "/var/www/$domain/index.html" ]; then
    rm -f "/var/www/$domain/index.html"
else
cp index.html $wwwDIR

# create conf file
availableDIR="/etc/nginx/sites-available/"
enabledDIR="/etc/nginx/sites-enabled/"
confFile="$domain.conf"
if [ -e "$availableDIR$conffile" ]; then
    rm -f "$availableDIR$conffile"
else
cat <<EOF >"$availableDIR$confFile"
server {
       listen 80 default_server;
       listen [::]:80 default_server ipv6only=on;

       server_name $domain www.domain;

       root /var/www/$domain;
       index index.html;

       location / {
               try_files $uri $uri/ =404;
       }
}
EOF

ln -s "$availableDIR$confFile" "$enabledDIR$confFile"

# start nginx
nginx -t
systemctl restart nginx
