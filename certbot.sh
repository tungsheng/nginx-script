# Install dependencies
sudo add-apt-repository "deb http://ftp.debian.org/debian stretch-backports main"
sudo apt update
apt-get -t stretch-backports install "package"

# Install certbot
apt-get install -y python-certbot-nginx -t stretch-backports

# Setup
certbot --authenticator webroot --installer nginx

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
