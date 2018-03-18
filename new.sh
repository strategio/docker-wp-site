#!/bin/bash
###########################################################
# This script will create WordPress site in a subfolder
# and running with its own containers and its virtual host
###########################################################

read -p 'Site name: ' SITE_HOST

echo "$(docker-machine ip)" $SITE_HOST >> '/c/Windows/System32/drivers/etc/hosts'
echo "- Added new site to host file."

mkdir $SITE_HOST
echo "- Created the directory $SITE_HOST."

cp "docker-compose.yml" "$SITE_HOST/docker-compose.yml"
echo "- Copied docker-compose.yml."

cd $SITE_HOST
sed -i -e 's/site-host/'"$SITE_HOST"'/g' ./docker-compose.yml
echo "- Added the virtual host."
echo

if [ ! "$(docker ps -a | grep 'nginx_proxy')" ]
then
	echo "Start NGINX Proxy"
	docker run -d -v "/var/run/docker.sock:/tmp/docker.sock:ro" \
		-p "80:80" -p "443:443" \
		--network="nginx-proxy" --name "nginx_proxy" jwilder/nginx-proxy
fi

docker-compose up -d

echo "Waiting for the containers to setup..."
sleep 15

echo "Restart $(docker restart nginx_proxy)"

echo "Waiting for NGINX Proxy to be ready..."
sleep 10

chrome "http://$SITE_HOST"
