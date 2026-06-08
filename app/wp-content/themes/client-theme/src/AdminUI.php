<?php

namespace Doubleedesign\ClientName;

class AdminUI {

    public function __construct() {
        // Note: This class should only be used for look-and-feel customisations to the admin.
        // Other admin customisations, such as customising the welcome screen ot Global Settings, belong in a plugin.
        add_filter('doublee_use_dark_bg_on_login_screen', '__return_false');
        add_filter('doublee_use_client_theme_in_admin', '__return_true');
    }
}
