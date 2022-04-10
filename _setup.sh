#!/bin/bash

. .env

network=''
debug=''

####################
# DEBUG
####################
if [ ! -z ${WORDPRESS_DEBUG} ]
then
    debug="$(
cat <<EOF

      WORDPRESS_DEBUG: ${WORDPRESS_DEBUG}
EOF
    )"
fi
####################

####################
# Networks
####################
if [ ! -z ${NETWORKS_DEFAULT_EXTERNAL_NAME} ]
then
    network="$(
cat <<EOF


networks:
  default:
    external:
      name: ${NETWORKS_DEFAULT_EXTERNAL_NAME}
EOF
    )"
fi
####################

cat > docker-compose.yml <<EOF
version: '3.3'

services:
  ${WORDPRESS_DOMAIN}:
    build: nginx
    restart: unless-stopped
    container_name: ${WORDPRESS_DOMAIN}
    depends_on:
      - ${WORDPRESS_ID}_wordpress
    volumes:
      - ncache:/ncache
      - ./wordpress:/var/www/html
      - ./nginx/logs:/var/log/nginx
      - ./nginx/${NGINX_CONF-standard}.conf:/etc/nginx/default.template
      - ./nginx/extras:/etc/nginx/extras
      - ./nginx/locations:/etc/nginx/locations
    environment:
      WP_HOST: ${WORDPRESS_ID}_wordpress:9000
      VIRTUAL_HOST: ${WORDPRESS_DOMAIN}
      LETSENCRYPT_HOST: ${WORDPRESS_DOMAIN}
    command: >
      /bin/sh -c "envsubst '\$\$WP_HOST'
      < /etc/nginx/default.template >
      /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
  ${WORDPRESS_ID}_wordpress:
    build: php
    restart: unless-stopped
    container_name: ${WORDPRESS_ID}_wordpress
    volumes:
      - ncache:/ncache
      - ./wordpress:/var/www/html
      - ./php/custom.ini:/usr/local/etc/php/conf.d/custom.ini
    environment:
      WORDPRESS_DB_HOST: ${WORDPRESS_DB_HOST}
      WORDPRESS_DB_NAME: ${WORDPRESS_DB_NAME}
      WORDPRESS_DB_USER: ${WORDPRESS_DB_USER}
      WORDPRESS_DB_PASSWORD: ${WORDPRESS_DB_PASSWORD}${debug}
      WORDPRESS_CONFIG_EXTRA: |
        define('WP_POST_REVISIONS', 3);

volumes:
  ncache:${network}
EOF
