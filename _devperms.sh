#!/bin/bash

. .env

docker exec -it -e GID=$(id -g) ${WORDPRESS_ID}_wordpress \
bash -c 'chgrp -R $GID ./ && chmod -R g+w ./*'