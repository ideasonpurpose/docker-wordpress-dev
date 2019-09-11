<?php

$scripts = json_decode(file_get_contents('/usr/src/package.json'))->scripts;
$package_json = json_decode(file_get_contents('/usr/src/site/package.json'));

echo "Merging Docker scripts into package.json";
$package_json->scripts = array_merge(
    (array) $package_json->scripts,
    (array) $scripts
);

echo "Writing updated package.json file";
file_put_contents(
    'new-pkg.json',
    json_encode(
        $package_json,
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT
    )
);
