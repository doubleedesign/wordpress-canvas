<?php
use Doubleedesign\ClientName\{AdminUI,NavMenus,ThemeStyle,TemplateConfig,TinyMceConfig,BlockEditorConfig};

require_once __DIR__ . '/vendor/autoload.php';

class ClientName {

    public function __construct() {
        new AdminUI();
        new NavMenus();
        new ThemeStyle();
        new TemplateConfig();
        new TinyMceConfig();
        new BlockEditorConfig();

        // Note: You can find a list of all Comet and Double-E filters and actions in .phpstorm.meta.php in the root of the project.
        // Run ./update-phpstorm-meta.ps1 from the root to update it.
        // This also provides IntelliSense for the filter and action names in PhpStorm.
    }
}

new ClientName();
