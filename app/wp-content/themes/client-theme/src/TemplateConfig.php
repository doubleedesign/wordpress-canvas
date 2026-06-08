<?php
namespace Doubleedesign\ClientName;

class TemplateConfig {

    public function __construct() {
        // Site header
        add_filter('comet_canvas_show_contact_details_in_header', '__return_false');
        add_filter('comet_canvas_show_contact_details_in_header_menu_overlay', '__return_true');

        // Blog index templates
        add_filter('comet_canvas_show_category_cards_on_blog_index', '__return_false');
        add_filter('comet_canvas_posts_loop_card_layout', function() { return 'list'; });
        add_filter('comet_canvas_posts_loop_card_list_container_size', function() { return 'contained'; });
        add_filter('comet_canvas_default_archive_width', function() { return 'contained'; });

        // Single blog post template
        add_filter('comet_canvas_blog_post_include_author_card', '__return_true');
        add_filter('comet_canvas_blog_post_include_post_nav', '__return_true');
        add_filter('comet_canvas_single_post_width', function() { return 'contained'; });
        add_filter('comet_canvas_single_post_image_aspect_ratio', function() { return 'cinemascope'; });
        add_filter('comet_canvas_single_post_featured_image_caption', '__return_false');
        add_filter('comet_canvas_show_avatar_in_author_bio', '__return_true');
    }
}
