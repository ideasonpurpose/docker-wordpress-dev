<?php

/**
 * Extra ideasonpurpose dev settings
 *
 * Enable all WordPress debugging constants
 * https://codex.wordpress.org/Debugging_in_WordPress
 *
 * Note: WP_DEBUG is set from the default entrypoint script based on
 *       the WORDPRESS_DEBUG env var in docker-compose.yml
 */
// define('WP_DEBUG', true);
define('WP_DEBUG_LOG', '/var/log/wordpress/debug.log');
define('WP_DEBUG_DISPLAY', true);
define('SCRIPT_DEBUG', true);
define('SAVEQUERIES', true);

/**
 * Useful idea from https://roots.io/
 */
define('WP_ENV', 'development');
