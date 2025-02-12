<?php
namespace Doubleedesign\CometCanvas;

use WP_Theme_JSON_Data;

class ThemeStyle {
	protected string $embedded_css = '';

	function __construct() {
		add_action('init', [$this, 'set_css_variables_from_theme_json'], 20, 1);
		add_action('wp_head', [$this, 'add_css_variables_to_head'], 25);
		add_action('wp_enqueue_scripts', [$this, 'enqueue_theme_stylesheets'], 20);

		add_action('admin_init', [$this, 'set_css_variables_from_theme_json'], 20, 1);
		add_action('admin_head', [$this, 'add_css_variables_to_head'], 25);

		if(is_admin()) {
			add_action('enqueue_block_assets', [$this, 'enqueue_theme_stylesheets'], 20);
			add_action('enqueue_block_assets', [$this, 'add_css_variables_to_block_editor'], 25);
		}
	}

	function set_css_variables_from_theme_json(): void {
		// Note: This needs to run after the same filter in the Comet Components plugin, or the theme object won't be correct
		add_filter('wp_theme_json_data_theme', function (WP_Theme_JSON_Data $theme_json) {
			$colours = $theme_json->get_data()['settings']['color']['palette']['theme'];
			$gradients = $theme_json->get_data()['settings']['color']['gradients']; // TODO: Implement gradients here
			$css = '';

			if(isset($colours)) {
				foreach($colours as $colourData) {
					$css .= '--color-' . $colourData['slug'] . ': ' . $colourData['color'] . ";\n";
				}
			}

			$this->embedded_css = $css;

			return $theme_json;
		}, 20, 1);
	}

	function add_css_variables_to_head(): void {
		echo '<style>:root {' . $this->embedded_css . '}</style>';
	}

	function add_css_variables_to_block_editor(): void {
		// Attaching this to comet-global-styles ensures it overrides Comet's global.css
		wp_add_inline_style('comet-global-styles', ":root { {$this->embedded_css} }");
	}

	function enqueue_theme_stylesheets(): void {
		$parent = get_template_directory(). '/style.css';
		$child = get_stylesheet_directory() . '/style.css';

		if(file_exists($parent)) {
			$parent = get_template_directory_uri() . '/style.css';
			wp_enqueue_style('comet-canvas', $parent, [], '0.0.1'); // TODO: Get this dynamically
		}

		if(file_exists($child)) {
			$child = get_stylesheet_directory_uri() . '/style.css';
			$theme = wp_get_theme();
			$slug = sanitize_title($theme->get('Name'));
			wp_enqueue_style($slug, $child, [], $theme->get('Version'));
		}
	}
}
