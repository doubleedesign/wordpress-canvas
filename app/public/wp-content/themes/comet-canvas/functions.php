<?php
require_once __DIR__ . '/vendor/autoload.php';
use Doubleedesign\CometCanvas\{ThemeStyle, NavMenus, SiteHealth, WpAdmin};

new ThemeStyle();
new NavMenus();
new SiteHealth();
new WpAdmin();
