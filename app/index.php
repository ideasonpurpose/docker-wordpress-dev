<?php

if (file_exists('/var/www/lib/kint/kint.phar')) {
  require('/var/www/lib/kint/kint.phar');
}

if (!function_exists('d')) {
  function d($arg)
  {
    printf("<pre>\n%s\n</pre>", htmlspecialchars(print_r($arg, true)));
  }
}


?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Docker Test</title>
</head>
<body>
<pre>
  Hello, Docker is loading a PHP file from nginx!!
  <?php

  echo json_encode(['message' => 'Welcome to PHP-7/MySQL on Docker']);

  error_log("Hello, I'm an error");

    // $db = new mysqli("db:3306", "wp_user", "wordpress", "wordpress");
    // print_r($db);

  file_put_contents('test.txt', 'hello test!');
  $varwww = scandir('/var/www');
  $varwwwhtml = scandir('/var/www/html');

  d($varwww);
  d($varwwwhtml);


  d('test');
  $file = file_get_contents('../wp-config.php');
  d($file);
  ?>

</pre>
  <?php phpinfo(); ?>
</body>
</html>
