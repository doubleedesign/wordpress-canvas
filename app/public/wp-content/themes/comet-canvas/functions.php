<?php
require_once __DIR__ . '/vendor/autoload.php';
use Doubleedesign\CometCanvas\{SiteHealth, WpAdmin};

new SiteHealth();
new WpAdmin();
