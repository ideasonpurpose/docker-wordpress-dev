<?php

namespace ideasonpurpose;

class WP_Image_Editor_Imagick_HQ extends \WP_Image_Editor_Imagick
{
    /**
     * This is just a simple wrapper around WP_Image_Editor_Imagick::thumbnail_image
     * which replaces the default FILTER_TRIANGLE with the much better FILTER_LANCZOS
     * resampling filter.
     */
    protected function thumbnail_image($dst_w, $dst_h, $filter_name = 'FILTER_LANCZOS', $strip_meta = true)
    {
        return parent::thumbnail_image($dst_w, $dst_h, $filter_name, $strip_meta);
    }
}
