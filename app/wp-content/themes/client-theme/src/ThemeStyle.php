<?php
namespace Doubleedesign\ClientName;

class ThemeStyle {

    public function __construct() {
        add_filter('comet_canvas_default_icon_prefix', function() { return 'fa-solid'; });
        add_filter('comet_canvas_component_defaults', [$this, 'set_component_defaults']);
        add_filter('comet_canvas_theme_colour_pairs_maybe', [$this, 'set_theme_colour_pairs']);
        add_filter('comet_blocks_colour_pair_overrides', [$this, 'customise_colour_pairs_for_some_blocks']);
        add_filter('comet_canvas_section_backgrounds', [$this, 'customise_available_section_backgrounds']);
    }

    public function set_component_defaults($defaults): array {
        // $defaults['call-to-action'] = array(
        // 'hAlign' => Alignment::CENTER
        // );

        return $defaults;
    }

    public function set_theme_colour_pairs(): array {
        return array(
            // ['white', 'primary', 2.1],
            // ['primary', 'white'],
        );
    }

    public function customise_colour_pairs_for_some_blocks($overrides): array {
        //        $overrides['call-to-action'] = array(
        //            ['foreground' => 'white', 'background' => 'primary']
        //        );

        return $overrides;
    }

    public function customise_available_section_backgrounds($backgrounds): array {

        return $backgrounds;
    }
}
