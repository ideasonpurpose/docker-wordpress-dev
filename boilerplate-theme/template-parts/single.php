<!-- START template-parts/single.php -->

<div>
  <h1>
    <a href="<?= get_post_type_archive_link($post->post_type) ?>">
      <?php the_title() ?>
    </a>
  </h1>

  <?php the_content(); ?>
</div>

<!-- END template-parts/single.php -->
