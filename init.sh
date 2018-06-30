function getDomain() {
    read -e -p "Enter a domain (e.g. domain.com) " -r domain
    if [[ "${#domain}" -lt 1 ]]; then
      echo " >> Please enter a valid domain!"
      readDomain
    fi
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
wwwFile="/var/www/$domain"
cp index.html $wwwFile

# create conf file
confFile="$domain.conf"
cp $confFile /etc/nginx/sites-available

ln -s /etc/nginx/sites-available/$confFile /etc/nginx/sites-enabled/$confFile

# start nginx
nginx -t
systemctl restart nginx
