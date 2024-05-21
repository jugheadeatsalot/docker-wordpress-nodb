#!/bin/bash

cd "$(dirname "$0")/.." || exit

# exit if no .env file
if [ ! -f .env ]; then
    echo "No .env file found. Exiting..."
    exit 1
fi

# shellcheck source=/dev/null
. .env

docker exec -it "wp_${WORDPRESS_ID}" \
    bash -c 'chgrp -R www-data ./ && chmod -R g-w ./*'
