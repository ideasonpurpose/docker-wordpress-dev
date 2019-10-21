<?php

namespace ideasonpurpose;

/**
 * Simple Helper which wraps a title-linked WP_Post in a list item
 * Keeps HTML cleaner
 */
$listWrapper = function ($li) {
    return sprintf('<li><a href="%s">%s</a></li>', $li->url, $li->title);
};

$nav_links = [];
$menus = get_nav_menu_locations();

if (array_key_exists('main-nav', $menus)) {
    $menu_id = $menus['main-nav'];
    $nav_links = wp_get_nav_menu_items($menu_id) ?: [];
    $nav_links = array_map($listWrapper, $nav_links);
}
?>

<nav id="menu-main" class="menu-main">
  <div class="menu-main__contents">
    <ul class="menu-main__list menu-main__container grid">
      <?= implode("\n", $nav_links) ?>
    </ul>
  </div>
</nav>
