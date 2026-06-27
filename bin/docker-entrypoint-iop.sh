#!/bin/bash

# This script is a part of the ideasonpurpose/docker-wordpress-dev project
# https://github.com/ideasonpurpose/docker-wordpress-dev
#
# Version: 2.0.0

RESET="\033[0m"
BOLD="\033[1m"
GOLD="\033[33m"

# # TODO: Remove once we're certain it's unused
# # This was never called. docker-compose files replace the entrypoint instead
# if [[ "$1" == permissions ]]; then
#   echo "${GOLD}DEPRECATED: Replace the entrypoint with /usr/local/bin/permissions${RESET}"
#   echo "${GOLD}            or call from docker-compose. (docker-entrypoint.sh)${RESET}"
#   /usr/local/bin/permissions.sh
#   exit 0
# fi

# If this is not a default run (matches known command) then exec the
# args and exit.
if [[ "$1" != apache2* ]] && [ "$1" != php-fpm ]; then
  exec "$@"
  exit 0
fi

# Remap Docker's entire ephemeral port range back to port 80
if iptables -t nat -L >/dev/null 2>&1; then
  iptables -t nat -A OUTPUT -p tcp -d "localhost" --dport 49153:65535 -j REDIRECT --to-port 80
else
  echo -e "${GOLD}WARNING: IPTables failed due to missing NET_ADMIN capability."
  echo -e "         Run with --cap-add=NET_ADMIN or add 'cap_add: [NET_ADMIN]' to docker-compose.yml.${RESET}"
fi

# Create a simple phpinfo() page at /info.php
echo '<?php phpinfo();' >/var/www/html/info.php
echo '<?php xdebug_info();' >/var/www/html/xdebug.php
chown www-data:www-data /var/www/html/info.php /var/www/html/xdebug.php

# Finally, we run the original endpoint, as intended, to kickoff the server
exec /usr/local/bin/docker-entrypoint.sh "$@"
