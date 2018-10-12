#!/bin/bash

# functions
get_host() {
  echo -e "\n\n"
  read -e -p "Enter a host (e.g. web.host.com) " -r host
  if [[ "${#host}" -lt 1 ]]; then
    echo " >> Please enter a valid host!"
    get_host
  fi
  echo -e "\n\n"
}

# get host name and init
get_host
wwwroot="/var/www/$host"
[[ -d "$wwwroot" ]] || sudo rm -rf $wwwroot

htmlDir="$wwwroot/html"
sudo mkdir -p $htmlDir
sudo cp $HOME/nginx-script/index.html $htmlDir

# update owner
sudo chown -R www-data:www-data $wwwroot
sudo chmod -R 755 $wwwroot

# setup server block 
availableDIR="/etc/nginx/sites-available"
enabledDIR="/etc/nginx/sites-enabled"
availableBlock="$availableDIR/$host"
enabledBlock="$enabledDIR/$host"
[ -d "$availableDIR" ] || sudo mkdir -p "$availableDIR"
[ -d "$enabledDIR" ] || sudo mkdir -p "$enabledDIR"
[ -f "$availableBlock" ] || sudo touch $availableBlock
[ -L "$enabledBlock" ] || sudo ln -s $availableBlock $enabledBlock

cat <<EOT > $availableBlock
server {
  listen 80;
  listen [::]:80;

  server_name $host;

  root $wwwroot/html;
  index index.html index.htm index.nginx-debian.html;
}
EOT

