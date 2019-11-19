<?php

namespace ideasonpurpose;

$autoloader = require __DIR__ . '/vendor/autoload.php';

new ThemeInit();

if (!defined('VERSION')) {
    define('VERSION', defined('WP_DEBUG') ? time() : wp_get_theme()->get('Version'));
}

/**
 * Initialize ideasonpurpose/GoogleAnalytics
 */
new GoogleAnalytics('UA-2565788-3');

/**
 * Initialize a logger
 */
$Log = new ThemeInit\Logger('iop');

/**
 * Initialize our SVG Library
 */
$SVG = new SVG();

/**
 * Register Custom Taxonomies
 */
// new Taxonomy\NAME();

/**
 * Register Custom Post Types
 */
// new CPT\NAME(22);

/**
 * Set separators for the WordPress admin
 */
new ThemeInit\Admin\Separators(20, 26, 28);

/**
 * Register Custom Widgets
 */
// new Widgets\NAME();

/**
 * Register Custom Menus
 */
add_action('after_setup_theme', function () {
  register_nav_menus([
      'main-nav' => 'Main Navigation',
      'footer-links' => 'Footer Links',
  ]);
});



/**
 * Load Scripts
 */
// TODO: What happens if this file doesn't exist yet?
new ThemeInit\Manifest(get_template_directory() . '/dist/dependency-manifest.json');
