<!-- START template-parts/components/search-form-header.php -->

<form class="search-form" method="get" role="search" action="<?= home_url('/') ?>">
  <button class="js-search-toggle" type="submit">
    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="19" viewBox="0 0 20 19">
      <g fill="none" fill-rule="evenodd" stroke="#FFF" stroke-width="2" transform="translate(1 1)">
        <circle cx="7" cy="7" r="7" />
        <path d="M13 12l5 5" />
      </g>
    </svg>
  </button>

  <input type="text" placeholder="Search Here..." value="" name="s" />

  <button class="visible-desktop js-search-toggle search-button-x">
    <svg xmlns="http://www.w3.org/2000/svg" width="23" height="23" viewBox="0 0 23 23">
      <g fill="none" fill-rule="evenodd" stroke="#FFF" stroke-width="2">
        <path d="M1 1l21 20.695M22 1L1 21.695" />
      </g>
    </svg>
  </button>
</form>

<!-- END template-parts/components/search-form-header.php -->