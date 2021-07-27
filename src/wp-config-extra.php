<?php

/**
 * Extra ideasonpurpose dev settings
 *
 * Since the 5.7 WordPress image, this file is included instead of parsed
 * ref: https://github.com/docker-library/wordpress/commit/891b7108294a629e6cc16c2f4bf643d9475894cc
 *
 * Serve WordPress internally from Docker's internal IP address
 */
define("WP_HOME", 'http://' . $_SERVER["SERVER_ADDR"]);
define("WP_SITEURL", 'http://' . $_SERVER["SERVER_ADDR"]);

/** Enable additional WordPress debugging constants
 * https://codex.wordpress.org/Debugging_in_WordPress
 *
 * WP_DEBUG is already set from Docker's WORDPRESS_DEBUG env var
 */
define("WP_DEBUG_LOG", "/var/log/wordpress/debug.log");
define("WP_DEBUG_DISPLAY", true);
define("SCRIPT_DEBUG", true);
define("SAVEQUERIES", true);

/**
 * Useful idea from https://roots.io/
 */
define("WP_ENV", "development");

/**
 * Explicitly define FS_METHOD so WordPress creates group-writeable files
 */
define('FS_METHOD', 'direct');
