#!/bin/bash

# exit if no .env file
if [ ! -f .env ]; then
    echo "No .env file found. Exiting..."
    exit 1
fi

# shellcheck source=/dev/null
. .env

docker exec -it -e GID="$(id -g)" "${WORDPRESS_ID}"_wordpress \
    bash -c 'chgrp -R $GID ./ && chmod -R g+w ./*'
