<?php
namespace Doubleedesign\ClientName;

class NavMenus {

    public function __construct() {
        add_filter('comet_canvas_nav_menus', [$this, 'customise_available_menus']);
    }

    public function customise_available_menus(array $menus): array {
        return $menus;
    }

}
