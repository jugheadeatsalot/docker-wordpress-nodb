#!/bin/bash

# exit if no .env file
if [ ! -f .env ]; then
  echo "No .env file found. Exiting..."
  exit 1
fi

# shellcheck source=/dev/null
. .env

network=''
environment=''

####################
# ENVIRONMENT
####################
if [ -n "${WP_ENVIRONMENT_TYPE}" ]; then
  environment="$(
    cat <<EOF

      WP_ENVIRONMENT_TYPE: ${WP_ENVIRONMENT_TYPE}
EOF
  )"
fi
####################

####################
# Networks
####################
if [ -n "${NETWORKS_DEFAULT_EXTERNAL_NAME}" ]; then
  network="
networks:
  default:
    name: ${NETWORKS_DEFAULT_EXTERNAL_NAME}
    external: true
"
fi
####################

cat >docker-compose.yml <<EOF
services:
  wp_nginx_${WORDPRESS_ID}:
    build: nginx
    restart: unless-stopped
    container_name: wp_nginx_${WORDPRESS_ID}
    depends_on:
      - wp_${WORDPRESS_ID}
    volumes:
      - ./ncache:/ncache
      - ./wordpress:/var/www/html
      - ./nginx/logs:/var/log/nginx
      - ./nginx/${NGINX_CONF-standard}.conf:/etc/nginx/default.template
      - ./nginx/extras:/etc/nginx/extras
      - ./nginx/locations:/etc/nginx/locations
    environment:
      WP_HOST: wp_${WORDPRESS_ID}:9000
      VIRTUAL_HOST: ${WORDPRESS_DOMAIN}
      LETSENCRYPT_HOST: ${WORDPRESS_DOMAIN}
    command: >
      /bin/sh -c "envsubst '\$\$WP_HOST'
      < /etc/nginx/default.template >
      /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
  wp_${WORDPRESS_ID}:
    build: php
    restart: unless-stopped
    container_name: wp_${WORDPRESS_ID}
    volumes:
      - ./ncache:/ncache
      - ./wordpress:/var/www/html
      - ./php/custom.ini:/usr/local/etc/php/conf.d/custom.ini
    environment:
      WORDPRESS_DB_HOST: ${WORDPRESS_DB_HOST}
      WORDPRESS_DB_NAME: ${WORDPRESS_DB_NAME}
      WORDPRESS_DB_USER: ${WORDPRESS_DB_USER}
      WORDPRESS_DB_PASSWORD: ${WORDPRESS_DB_PASSWORD}${environment}
      WORDPRESS_CONFIG_EXTRA: |
        define('WP_POST_REVISIONS', 3);
        define('RT_WP_NGINX_HELPER_CACHE_PATH', '/ncache');
        define('NGINX_HELPER_LOG', true);
${network}
EOF
