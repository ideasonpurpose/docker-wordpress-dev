<?php

/**
 * TODO: Move this into a separate file
 * TODO: No longer necessary?
 * TODO: Clean up this mess
 *
 * Get this container's ephemeral port on the Host via the Docker API
 */

// translating this
// @link https://sleeplessbeastie.eu/2021/12/13/how-to-query-docker-socket-using-curl/
//    curl --silent -XGET --unix-socket /run/docker.sock http://localhost/containers/0a8a082812a1/json | jq .

$protocol = isset($_SERVER["HTTPS"]) ? 'https' : 'http';
// $hostname = gethostname();
// $socket = "/run/docker.sock";
// $req  = "http://localhost/containers/{$hostname}/json";
// $host = "{$protocol}://{$_SERVER['HTTP_HOST']}";

// $curl = curl_init();
// curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
// curl_setopt($curl, CURLOPT_UNIX_SOCKET_PATH, $socket);
// curl_setopt($curl, CURLOPT_URL, $req);
// $info = curl_exec($curl);
// $info = json_decode($info);

// $wp_port =  (integer) $info->NetworkSettings->Ports->{'80/tcp'}[0]->HostPort;


// d($_SERVER, $hostname, $socket, $req, $info , $wp_port);



/**
 * Extra ideasonpurpose dev settings
 *
 * Since the 5.7 WordPress image, this file is included instead of parsed
 * ref: https://github.com/docker-library/wordpress/commit/891b7108294a629e6cc16c2f4bf643d9475894cc
 *
 * Serve WordPress internally from Docker's internal IP address
 */
// define('WP_HOME', 'http://' . $_SERVER['SERVER_ADDR']);
// define('WP_SITEURL', 'http://' . $_SERVER['SERVER_ADDR']);
// define('WP_HOME', 'http://localhost:' . $_ENV['WP_PORT']);
// define('WP_SITEURL', 'http://localhost:' . $_ENV['WP_PORT']);
// define('WP_HOME', "http://localhost:{$wp_port}");
// define('WP_SITEURL', "http://localhost:{$wp_port}");
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
