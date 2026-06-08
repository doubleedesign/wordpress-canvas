<?php

namespace Doubleedesign\ClientName;

class TinyMceConfig {

    public function __construct() {
        add_filter('doublee_tinymce_styleselect_formats', [$this, 'customise_tinymce_styleselect_formats']);
    }

    public function customise_tinymce_styleselect_formats(array $groups): array {
        return $groups;
    }
}
