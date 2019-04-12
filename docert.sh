#!/bin/bash

if [ $# -gt 0 ]; then
  certbot certonly \
    --dns-digitalocean \
    --dns-digitalocean-credentials ~/.secrets/certbot/digitalocean.ini \
    -d $1 \
else
    echo "Need to pass domain..."
fi
