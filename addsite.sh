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
sudo cp $HOME/nginx-script/index.html $htmlDir

# update owner
sudo chown -R www-data:www-data $wwwroot
sudo chmod -R 755 $wwwroot

# setup server block 
availableDIR="/etc/nginx/sites-available"
[ -d "$availableDIR" ] || mkdir -p "$availableDIR"
enabledDIR="/etc/nginx/sites-enabled"
[ -d "$enabledDIR" ] || mkdir -p "$enabledDIR"
serverblock="$availableDIR/$domain"
[ ! -f "$serverblock" ] && sudo touch $serverblock

cat <<EOF > "$availableDIR/$domain"
server {
  listen 80;

  server_name $domain www.$domain;

  root $wwwroot/html;
  index index.html index.htm index.nginx-debian.html;

  location / {
    try_files ${uri@Q} ${uri@Q}/ =404;
  }
}
EOF

sudo ln -s "$availableDIR/$domain" "$enabledDIR/$domain"

# reload nginx
sudo nginx -t
sudo systemctl reload nginx

exit 0
