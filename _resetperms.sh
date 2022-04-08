#!/bin/bash

. .env

docker exec -it ${WORDPRESS_ID}_wordpress \
bash -c 'chgrp -R www-data ./ && chmod -R g-w ./*'