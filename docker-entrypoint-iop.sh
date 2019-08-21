#!/bin/bash

# If this is not a default run (matches known command) then exec the
# args and exit.
if [[ "$1" != apache2* ]] && [ "$1" != php-fpm ]; then
  exec $@
  exit 0
fi

# Otherwise, add our extras to wp-config.php and pass the args to
# the parent entrypoint script.

# Remove wp-config.php so we start fresh every time
# echo 'Removing existing wp-config.php file'

# rm -f wp-config.php
if [ -f wp-config.php ]; then
    echo
    echo 'Rename existing wp-config.php file'
    mv wp-config.php $(mktemp wp-config.php.XXXX)
    echo
fi

# pause to make sure we don't race
# sleep 1

# Our wp-config.php additions
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


# Thanks to a loose match in the base entrypoint, we can "trick" the script
# into configuring WordPress without starting Apache. Then we run our own script
# to modify wp-config.php and finally launch the original endpoint.
#
# note: If this breaks in the future, rename /usr/local/bin/apache-foreground
# and replace it with a dummy script.

/usr/local/bin/docker-entrypoint.sh apache2ctl -v



# The default WordPress entrypoint needs to run before this, but it never exits
# So, we throw our functions into a background job and call the parent entrypoint
# {
# while [ ! -s wp-config.php ]; do echo "Waiting for WordPress setup..."; sleep 1; done

if  [[ "$(< wp-config.php)" != *"Extra ideasonpurpose dev settings"* ]]; then

  echo "Updating wp-config, injecting: "
  echo
  echo "$WP_EXTRA_DEBUG"
  echo

  awk -v wp="$WP_EXTRA_DEBUG\n" '/^\/\*.*stop editing.*\*\/$/ && c == 0 {c=1; print wp}{print}' wp-config.php > wp-config.tmp
  mv wp-config.tmp wp-config.php

  # TODO: Do this somewhere else, preferrably with wp-cli
  # Set the active theme to $WORDPRESS_ACTIVE_THEME if variable is set and not empty
#   if [ ! -z "$WORDPRESS_ACTIVE_THEME" ]; then
#       while ! mysqladmin ping -u root -h db --silent; do echo "Waiting for db..."; sleep 1; done
#       MYSQL_SET_THEME="UPDATE wp_options \
#                        SET option_value = '$WORDPRESS_ACTIVE_THEME' \
#                        WHERE option_name IN ('template', 'stylesheet');"
#       mysql wordpress -h db -u root -e "$MYSQL_SET_THEME"
#   fi

else
  echo "Config already has dev additions"
fi
# } &


# Finally, we run the original endpoint, as intended, to kickoff the sever
/usr/local/bin/docker-entrypoint.sh $1
