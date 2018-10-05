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

# update source
curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
echo "deb https://nginx.org/packages/mainline/debian/ $(lsb_release -cs) nginx\n" | tee -a /etc/apt/sources.list.d/nginx.list
echo "deb-src https://nginx.org/packages/mainline/debian/ $(lsb_release -cs) nginx" | tee -a /etc/apt/sources.list.d/nginx.list

# install nginx
apt-get remove nginx-common
apt-get update
apt-get install -y nginx

# add Nginx service
echo -ne "Adding Nginx service...\n"
touch /lib/systemd/system/nginx.service
cat <<EOT >> /lib/systemd/system/nginx.service
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
fi
cp index.html $wwwDIR

# create conf file
availableDIR="/etc/nginx/sites-available/"
enabledDIR="/etc/nginx/sites-enabled/"
confFile="$domain.conf"
echo -e "$confFile"
if [ -e "$availableDIR$conffile" ]; then
    rm -f "$availableDIR$confFile"
    rm -f "$enabledDIR$confFile"
fi
cat <<EOF >"$availableDIR$confFile"
http {
  server {
    listen 80 default_server;

    server_name $domain www.$domain;

    root /var/www/$domain;
    index index.html;
  }
}
EOF

ln -s "$availableDIR$confFile" "$enabledDIR$confFile"

mv $availableDIR"default" $availableDIR"default-old"

# start nginx
nginx -t
systemctl restart nginx

source certbot.sh

exit 0
