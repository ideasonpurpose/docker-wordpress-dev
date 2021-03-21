#!/bin/bash

if [[ "$1" == init ]]; then
  /usr/local/bin/wp-init.sh
  /usr/local/bin/permissions.sh
  exit 0
fi

# TODO: Remove once we're certain it's unused
# This was never called. docker-compose files replace the entrypoint instead
if [[ "$1" == permissions ]]; then
  echo "DEPRECATED: Replace the entrypoint with /usr/local/bin/permissions"
  echo "            or call from docker-compose."
  /usr/local/bin/permissions.sh
  exit 0
fi

# If this is not a default run (matches known command) then exec the
# args and exit.
if [[ "$1" != apache2* ]] && [ "$1" != php-fpm ]; then
  exec "$@"
  exit 0
fi

# Create a simple phpinfo() page at /info.php
echo '<?php phpinfo();' >/var/www/html/info.php

# Finally, we run the original endpoint, as intended, to kickoff the server
exec /usr/local/bin/docker-entrypoint.sh "$@"
