#!/bin/bash

# exit if no .env file
if [ ! -f .env ]; then
    echo "No .env file found. Exiting..."
    exit 1
fi

# shellcheck source=/dev/null
. .env

docker exec -it "${WORDPRESS_ID}"_wordpress \
    bash -c 'chgrp -R www-data ./ && chmod -R g-w ./*'
