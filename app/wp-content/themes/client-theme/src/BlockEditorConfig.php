<?php
namespace Doubleedesign\ClientName;

class BlockEditorConfig {

    public function __construct() {
        add_filter('comet_allowed_blocks', [$this, 'filter_allowed_blocks'], 11);
        add_filter('comet_blocks_related_content_card_list_behaviour_when_fewer_than_max', function() { return 'expand'; });
        add_filter('comet_blocks_related_content_max_per_row', function() { return 3; });
    }

    public function filter_allowed_blocks($blocks): array {
        return $blocks;
    }
}
