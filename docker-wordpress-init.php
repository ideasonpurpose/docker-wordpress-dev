<?php

$pkg = @file_get_contents('/usr/src/site/package.json') ?: '{}';
$package_json = json_decode($pkg);
$scripts = json_decode(file_get_contents('/usr/src/package.json'))->scripts;

echo "Merging Docker scripts into package.json\n";
$package_json->scripts = (object) array_merge(
    property_exists($package_json, 'scripts') ?  (array) $package_json->scripts : [],
    (array) $scripts
);

echo "Writing updated package.json file\n";
file_put_contents(
    '/usr/src/site/package.json',
    json_encode(
        $package_json,
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT
    ) . "\n"
);
