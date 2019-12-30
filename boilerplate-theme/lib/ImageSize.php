<?php

namespace ideasonpurpose;

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

class ImageSize
{
    public function __construct($image_sizes)
    {
        $this->sizes = $image_sizes;
        $this->names = [];

        add_action('after_setup_theme', [$this, 'addSizes']);
        add_filter('image_size_names_choose', [$this, 'addToMenu']);
    }

    public function addSizes()
    {
        foreach ($this->sizes as $img) {
            $crop = false;
            if (isset($img['crop'])) {
                $crop = is_array($img['crop']) ? $img['crop'] : boolval($img['crop']);
            }
            add_image_size($img['name'], $img['dims'][0], $img['dims'][1], $crop);
            if (isset($img['display'])) {
                $this->names[$img['name']] = $img['display'];
            }
        }
    }

    /**
     * Adds our custom sizes to the WordPress image size menu
     * @param array $sizes Array of image sizes passed from the image_size_names_choose filter
     */
    public function addToMenu($sizes)
    {
        return array_merge($sizes, $this->names);
    }

    /**
     * Add a filter to remove $sizes from the WordPress thumbnail generation
     * @param array $sizes    An associative array of image sizes.
     */
    public static function removeSizes($sizes)
    {
        add_filter('intermediate_image_sizes_advanced', function ($defaultSizes) use ($sizes) {
            foreach ($sizes as $size) {
                unset($defaultSizes[$size]);
            }
            return $defaultSizes;
        });
    }
}
