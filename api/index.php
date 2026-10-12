<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Vercel's filesystem is read-only except /tmp, so Laravel's storage
// directory must live there. Create it before anything tries to write.
$storage = '/tmp/storage';

foreach ([
    "$storage/app/public",
    "$storage/framework/cache/data",
    "$storage/framework/sessions",
    "$storage/framework/views",
    "$storage/logs",
    "$storage/bootstrap/cache",
] as $dir) {
    if (!is_dir($dir)) {
        mkdir($dir, 0755, true);
    }
}

// Register the Composer autoloader...
require __DIR__.'/../vendor/autoload.php';

// Bootstrap Laravel and handle the request...
/** @var Application $app */
$app = require_once __DIR__.'/../bootstrap/app.php';

$app->useStoragePath($storage);

$app->handleRequest(Request::capture());