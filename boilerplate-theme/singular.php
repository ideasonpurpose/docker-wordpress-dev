<?php
namespace ideasonpurpose;

get_header();

while (have_posts()) {
    the_post();

    get_template_part('template-parts/single', get_post_type());
}

get_footer();
