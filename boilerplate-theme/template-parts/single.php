<!-- START template-parts/single.php -->

<main>
  <article class="post">

    <h1>
      <a href="<?= get_post_type_archive_link($post->post_type) ?>">
        <?php the_title() ?>
      </a>
    </h1>

    <section class="editorial wrapper">
      <?php the_content(); ?>
    </section>

  </article>
</main>

<!-- END template-parts/single.php -->
