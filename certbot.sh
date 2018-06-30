sudo apt-get update
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y certbot python-certbot-nginx
sudo certbot --authenticator webroot --installer nginx

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
