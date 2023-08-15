#!/bin/bash


echo uninstalling apache
sudo apt purge -y apache apache2

if [ $? -ne 0 ]; then
  echo Unable to remove apache
  exit 1
fi

nginx -v 
if [ $? -ne 0 ]; then
  echo nginx not installed installing...
  
  ## update packages
  echo updating packages ...
  sudo apt -y update

  if [ $? -ne 0 ]; then
    echo Unable to Update Packages
    exit 1
  fi


  ## install nginx
  echo installing nginx
  sudo apt install -y nginx

  if [ $? -ne 0 ]; then
    echo Unable to Install Nginx
    exit 1
  fi
fi

## enable firewall
echo Enabling Firewall
sudo ufw allow 'Nginx HTTP'


if [ $? -ne 0 ]; then
  echo Unable to Install Nginx
  exit 0
fi

echo Enter The domain without www.
read DOMAIN

echo Enter the local port your server is running
read PORT

LOCAL_SERVER=http://localhost:$PORT

# AVAILABLE_DIR=/etc/nginx/sites-available
# ENABLED_DIR=/etc/nginx/sites-enabled

AVAILABLE_DIR=./test/available
ENABLED_DIR=./test/enabled

cat > $AVAILABLE_DIR/$DOMAIN << EOF
server {
    server_name $DOMAIN www.$DOMAIN;

    location / {
        proxy_pass $LOCAL_SERVER;
    }
}
EOF

sudo ln -s $AVAILABLE_DIR/$DOMAIN $ENABLED_DIR/$DOMAIN

sudo nginx -s reload || true



