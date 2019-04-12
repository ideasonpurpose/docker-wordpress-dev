#!/bin/bash

WP_EXTRA_DEBUG=$( cat <<'EOF'
/**
  * Extra ideasonpurpose dev settings
  *
  * Enable all WordPress debugging constants
  * https://codex.wordpress.org/Debugging_in_WordPress
  */
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', true);
define('SCRIPT_DEBUG', true);
define('SAVEQUERIES', true);

/**
  * Useful idea from https://roots.io/
  */
define('WP_ENV', 'development');

EOF
);


# The default WordPress entrypoint needs to run before this, but it never exits
# So, we throw all of our functions into a background job and call the parent entrypoint
{
while [ ! -s wp-config.php ]; do echo "Waiting for WordPress setup..."; sleep 1; done

if  [[ "$(< wp-config.php)" != *"Extra ideasonpurpose dev settings"* ]]; then

  echo "Updating wp-config, injecting: "
  echo
  echo "$WP_EXTRA_DEBUG"
  echo

  awk -v wp="$WP_EXTRA_DEBUG\n" '/^\/\*.*stop editing.*\*\/$/ && c == 0 {c=1; print wp}{print}' wp-config.php > wp-config.tmp
  mv wp-config.tmp wp-config.php

  # # TODO: This seems tightly coupled. Suddenly the entrypoint knows about the environment and the dockerfile DB hostname??!
  # while ! mysqladmin ping -u root -h db --silent; do echo "Waiting for db..."; sleep 2; done
  # #
  # # Set the active theme to the project name
  # MYSQL_SET_THEME='UPDATE wp_options SET option_value = "iop12" WHERE option_name IN ("template", "stylesheet")' wordpress
  # mysql -h db -u root wordpress -e $MYSQL_SET_THEME
else
  echo "Config already has dev additions"
fi
} &
/usr/local/bin/docker-entrypoint.sh $1
