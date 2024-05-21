#!/bin/bash

cd "$(dirname "$0")/.." || exit

# exit if no .env file
if [ ! -f .env ]; then
    echo "No .env file found. Exiting..."
    exit 1
fi

# shellcheck source=/dev/null
. .env

docker exec -it -e GID="$(id -g)" "wp_${WORDPRESS_ID}" \
    bash -c 'apk add curl php-cli php-mbstring git unzip && \
    cd /devtools &&
    curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    composer require squizlabs/php_codesniffer --dev'
