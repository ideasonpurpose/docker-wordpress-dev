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
 * Register Custom Shortcodes
 */
// new Shortcodes\NAME();

/**
 * Register Custom Menus
 */
add_action('after_setup_theme', function () {
    register_nav_menus([
        'main-nav' => 'Main Navigation',
        'footer-links' => 'Footer Links'
    ]);
});

/**
 * Load Scripts
 */
// TODO: What happens if this file doesn't exist yet?
new ThemeInit\Manifest(get_template_directory() . '/dist/dependency-manifest.json');

/**
 * Enable assorted WordPress features
 */
add_action('after_setup_theme', function () {
    // Add excerpts to pages
    add_post_type_support('page', 'excerpt');

    // Theme features
    add_theme_support('post-thumbnails');
    add_theme_support('title-tag');
    add_theme_support('html5', ['search-form', 'gallery', 'caption']);

    // Gutenberg settings
    add_theme_support('editor-styles'); // https://developer.wordpress.org/block-editor/developers/themes/theme-support/#editor-styles
    add_theme_support('align-wide'); // https://wordpress.org/gutenberg/handbook/extensibility/theme-support/#wide-alignment
    add_theme_support('disable-custom-colors'); // https: //wordpress.org/gutenberg/handbook/extensibility/theme-support/#disabling-custom-colors-in-block-color-palettes
    // add_theme_support('editor-color-palette', [
    //     ['name' => 'White', 'slug' => 'white', 'color' => '#fff'],
    //     ['name' => 'Black', 'slug' => 'black', 'color' => '#000']
    // ]);
});

/**
 * Define additional image sizes
 * Image sizes are generated from an array of size objects
 * Each size maps like this:
 *   name:     (string)   Internal image size name (slug)
 *   dims:     (array)    Array of two integers: [w, h]
 *   display:  (string)   Show in WP Menus using this name
 *   crop:     (array|boolean)  if not false, hard-crop the resulting image
 *
 * If display_name is specified, the image size will appear in authoring menus
 */
$image_sizes = [
    ['name' => '1k', 'dims' => [1024, 1024], 'display' => '1k - 1024px'],
    ['name' => '2k', 'dims' => [2048, 2048], 'display' => '2k - 2048px'],
    ['name' => '4k', 'dims' => [3840, 3840], 'display' => '4k - 3840px']
];

new ImageSize($image_sizes);

/**
 * Set JPEG compression quality to 65. This is lower than the default WordPress value, but most
 * images should be @2x or grater, so this could probably go lower without a problem.
 *
 * TODO: This should move into our WP_Image_Editor_Imagick_HQ class
 */
add_filter('jpeg_quality', function () {
    return 65;
});

/**
 * Compress every image uploaded to WordPress
 *
 * TODO: Move this into wp-theme-init
 */
add_filter(
    'wp_generate_attachment_metadata',
    function ($metadata, $attachment_id) {
        /**
         * Check to see if 'original_image' has been created yet (`big_image_size_threshold` filter)
         * If not, save out an optimized copy and update image metadata
         */
        if (!array_key_exists('original_image', $metadata)) {
            $uploads = wp_upload_dir();
            $srcFile = $uploads['basedir'] . '/' . $metadata['file'];
            $editor = wp_get_image_editor($srcFile);

            if (is_wp_error($editor)) {
                error_log("File $metadata[file] can not be edited.");
                return $metadata;
            }

            /**
             * WordPress does not expose the Imagick object from `wp_get_image_editor`
             * so there's no way to get the compressed image's filesize before it's written
             * to disk.
             */
            $saved = $editor->save($editor->generate_filename('optimized'));

            if (is_wp_error($saved)) {
                error_log('Error trying to save.', $saved->get_error_message());
            } else {
                /**
                 * Compare filesize of the optimized image against the original
                 * If the optimized filesize is less than 75% of the original, then
                 * use the use the optimized image. If not, remove the optimized
                 * iamge and keep using the original image.
                 */
                if (filesize($saved['path']) / filesize($srcFile) < 0.75) {
                    // Optimization successful, update $metadata to use optimized image
                    // Ref: https://developer.wordpress.org/reference/functions/_wp_image_meta_replace_original/
                    update_attached_file($attachment_id, $saved['path']);
                    $metadata['original_image'] = basename($metadata['file']);
                    $metadata['file'] = dirname($metadata['file']) . '/' . $saved['file'];
                } else {
                    // Optimization not worth it, delete optimized file and use original
                    unlink($saved['path']);
                }
            }
        }
        return $metadata;
    },
    10,
    2
);

/**
 * Store theme settings under the theme basename
 * This prevents menus and other theme-dependent settings from
 * being lost on version bumps.
 *
 * TODO: Move this into wp-theme-init
 *
 * Write options to themeBasename
 */
add_filter(
    'pre_update_option_theme_mods_' . get_option('stylesheet'),
    function ($val, $oldVal, $opt) {
        $optBase = preg_replace("/-\d+_\d+_\d+$/", '', $opt);
        // Trying to update when optBase and $opt are the same will nest infinitely
        if ($optBase !== $opt) {
            update_option($optBase, $val);
            // short-circuit from here and return $oldVal, no need
            // to write an extra wp_options entry
            return $oldVal;
        }
        return $val;
    },
    10,
    3
);

/**
 * Strip version numbers from theme names before writing options
 */
add_filter(
    'option_theme_mods_' . get_option('stylesheet'),
    function ($val, $opt) {
        $optBase = preg_replace("/-\d+_\d+_\d+$/", '', $opt);
        // if $optBase and $opt match, getting the option will nest infinitely
        return $optBase === $opt ? $val : get_option($optBase);
    },
    10,
    2
);

/**
 * Enable our WP_Image_Editor_Imagick_HQ class for better scaling
 * TODO: Move into wp-theme_init
 */
add_filter('wp_image_editors', function ($editors) {
    array_unshift($editors, __NAMESPACE__ . '\\WP_Image_Editor_Imagick_HQ');
    return $editors;
});
