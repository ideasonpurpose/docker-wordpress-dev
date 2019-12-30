<?php

namespace ideasonpurpose;

$menu_locations = get_nav_menu_locations();
$menus = [];
$menu_key = 'main-nav';
if (array_key_exists($menu_key, $menu_locations) && $menu_locations[$menu_key] !== 0) {
    $menu_id = intval($menu_locations[$menu_key]);
    $menus[$menu_key] = wp_nav_menu([
        'menu' => $menu_id,
        'menu_class' => 'menu menu--main',
        'items_wrap' => '<ul class="%2$s">%3$s</ul>' . "\n",
        'container' => '',
        'echo' => false
    ]);
}
?>

<!-- START template-parts/components/header.php -->

<header class="header">
  <nav class="header__container wrapper">
    <div class="header__bar wrapper--bleed-mobile wrapper--bleed-tablet">
      <a class="header__logo" href="<?= bloginfo('url') ?>">
        LOGO
      </a>

      <button type="button" class="menu-button">
        <span class="menu-button__lines"></span>
        <span class="a11y">Toggle main menu</span>
      </button>
    </div>

    <div class="header__menu">
      <?php get_template_part('template-parts/components/search-form', 'header'); ?>
      <?= $menus[$menu_key] ?>
    </div>
  </nav>
</header>

<!-- END template-parts/components/header.php -->
