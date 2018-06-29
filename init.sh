apt-get install -y nginx
mkdir -p "/var/www/$domain"

cp index.html /var/www/mydomain.com
cp domain.com.conf /etc/nginx/sites-available
ln -s /etc/nginx/sites-available/mydomain.com.conf /etc/nginx/sites-enabled/mydomain.com.conf

nginx -t
systemctl restart nginx
