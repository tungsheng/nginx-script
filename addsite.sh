#!/bin/bash

# functions
get_domain() {
  echo -e "\n\n"
  read -e -p "Enter a domain (e.g. domain.com) " -r domain
  if [[ "${#domain}" -lt 1 ]]; then
    echo " >> Please enter a valid domain!"
    get_domain
  fi
  echo -e "\n\n"
}

# get domain name and init
get_domain
wwwroot="/var/www/$domain"
[[ -d "$wwwroot" ]] || sudo rm -rf $wwwroot

htmlDir="$wwwroot/html"
sudo mkdir -p $htmlDir
sudo cp index.html $htmlDir

# setup server block 
availableDIR="/etc/nginx/sites-available"
enabledDIR="/etc/nginx/sites-enabled"
serverblock="$availableDIR/$domain"

[[ -f "$serverblock" ]] || sudo rm -f "$serverblock"

sudo touch $serverblock
cat <<EOF >> "$availableDIR/$domain"
server {
  listen 80;
  listen [::]:80;

  root $wwwroot/html;
  index index.html index.htm index.nginx-debian.html;

  server_name $domain www.$domain;

  location / {
    try_files $uri $uri/ =404;
  }
}
EOF

sudo ln -s "$availableDIR/$domain" "$enabledDIR/$domain"

# reload nginx
nginx -t
systemctl reload nginx

exit 0
