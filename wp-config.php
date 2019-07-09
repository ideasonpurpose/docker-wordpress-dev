<?php

/**
 * Vagrant overrides
 */

define('WP_HOME', 'http://iop.test');
define('WP_SITEURL', 'http://iop.test');
define('WP_ENV', 'development');

define('WP_CONTENT_DIR', '/var/www/html/site/wp-content');
define('WP_CONTENT_URL', WP_SITEURL . '/wp-content');

/**
 * Enable debugging
 */
if ( !defined('WP_DEBUG') )
    define('WP_DEBUG', true);
if ( !defined('WP_DEBUG_LOG') )
    define('WP_DEBUG_LOG', true);
if ( !defined('WP_DEBUG_DISPLAY') )
    define('WP_DEBUG_DISPLAY', true);
if ( !defined('SCRIPT_DEBUG') )
    define('SCRIPT_DEBUG', true);
if ( !defined('SAVEQUERIES') )
    define('SAVEQUERIES', true);

/**
 * Include the Kint PHP debugging helper
 * http://kint-php.github.io/kint/
 */

// include_once('/var/www/html/site/kint/kint.phar');


/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'wordpress');

/** MySQL database username */
define('DB_USER', 'wordpress');

/** MySQL database password */
define('DB_PASSWORD', 'wordpress');

/** MySQL hostname */
define('DB_HOST', 'db:3306');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '0BJ14EBqA5KDcr2;|D?BAqFf`jKf@#LJ[7{:@rsY|[j._6Fx#l0,ZVG1IcEExG!P');
define('SECURE_AUTH_KEY',  ';dkHdtVtE(A!i*na?XPqe+-Ptcn6f7Nh~)WMb+%E-]|C:hUaLR=gCH kFV+*3N1o');
define('LOGGED_IN_KEY',    'bcvynx,-|9h|`@/Dl|8G6}S`kA6_+c|tMt!L{H02/6Fmb%}Ju7T%1~bU^,:~1aMu');
define('NONCE_KEY',        '9ToDNx=Ls2+uCke^{B.O0+F$3Q!!=4yA0d6R,&>)H++z<e>y[O]JzHPPP_MKobNT');
define('AUTH_SALT',        'V,@U_))}>2zk@B[p_Zo[,u*!em[<3g-srJo[%ixO*n8C%4-:]D~MS>=-d@Y*ZS2%');
define('SECURE_AUTH_SALT', '0!@u4BrIAU;C^j>O{49#<Rboj|qG0TZ~B!2(b12=/SL)L0O*-#LxIE=H-%y`s~Xs');
define('LOGGED_IN_SALT',   '2D3/}~wEjHg-Hsn`.vQucAuGBGgZ|eht5e7|A!^*%}sGkz4^AUW/)+DG(k[=JwHh');
define('NONCE_SALT',       'O5^9`b7-9B`y?O9FB-`jy|kU<D<N3${3,V0@k;bC}}DlqmNleEU&Ua_H~7/0V1:D');


/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the Codex.
 *
 * @link https://codex.wordpress.org/Debugging_in_WordPress
 */
// define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
