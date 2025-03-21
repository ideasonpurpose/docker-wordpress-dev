<?php

$protocol = isset($_SERVER['HTTPS']) ? 'https' : 'http';

/**
 * Extra ideasonpurpose dev settings
 *
 * Since the 5.7 WordPress image, this file is included instead of parsed
 * ref: https://github.com/docker-library/wordpress/commit/891b7108294a629e6cc16c2f4bf643d9475894cc
 */
define('WP_HOME', "{$protocol}://{$_SERVER['HTTP_HOST']}");
define('WP_SITEURL', "{$protocol}://{$_SERVER['HTTP_HOST']}");

/**
 * Enable additional WordPress debugging constants when WP_DEBUG is true
 * https://codex.wordpress.org/Debugging_in_WordPress
 *
 * WP_DEBUG will already be defined and set based on Docker's WORDPRESS_DEBUG env var,
 * no need to check that the constant exists first
 * @link https://github.com/docker-library/wordpress/blob/e98fe75c5a41e2d3f3c4d89f3e6b15e62638147c/wp-config-docker.php#L110
 */
if (WP_DEBUG) {
    define('WP_DEBUG_LOG', '/var/log/wordpress/debug.log');
    define('WP_DEBUG_DISPLAY', true);
    /**
     * Disable caching of theme-related *.json files
     * @link https://github.com/ideasonpurpose/docker-wordpress-dev/issues/72
     */
    define('WP_DEVELOPMENT_MODE', 'theme');
    define('SCRIPT_DEBUG', true);
    define('SAVEQUERIES', true);
}

/**
 * Default WP_ENVIRONMENT_TYPE to 'development' unless an environment variable is set
 * https://developer.wordpress.org/reference/functions/wp_get_environment_type/
 * https://make.wordpress.org/core/2020/07/24/new-wp_get_environment_type-function-in-wordpress-5-5/
 */
define('WP_ENVIRONMENT_TYPE', getenv('WP_ENVIRONMENT_TYPE') ?: 'development');

/**
 * Explicitly define FS_METHOD so WordPress creates group-writeable files
 */
define('FS_METHOD', 'direct');
