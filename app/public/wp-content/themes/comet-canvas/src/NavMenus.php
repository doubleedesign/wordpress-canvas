<?php
namespace Doubleedesign\CometCanvas;

class NavMenus {

	public function __construct() {
		add_action('init', [$this, 'register_menus'], 20);
		add_filter('nav_menu_link_attributes', [$this, 'menu_link_classes'], 10, 4);
		add_filter('nav_menu_submenu_css_class', [$this, 'menu_submenu_classes'], 10, 2);
		add_action('rest_api_init', [$this, 'make_menus_available_in_rest']);
	}

	/**
	 * Register menus in the back-end
	 * @return void
	 */
	function register_menus(): void {
		register_nav_menus(array(
			'primary' => 'Primary menu',
			'mobile'  => 'Mobile (small viewport) alternative primary menu',
			'footer'  => 'Footer menu'
		));
	}


	/**
	 * Add classes to menu <a> tags
	 * @param $atts
	 * @param $item
	 * @param $args
	 * @param $depth
	 *
	 * @return array
	 */
	function menu_link_classes($atts, $item, $args, $depth): array {
		if ($args->theme_location == 'header' && $depth == 0 && in_array('menu-item-has-children', $item->classes)) {
			$atts['class'] = 'menu-dropdown-link';
		}

		return $atts;
	}

	/**
	 * Add classes to sub-menu <ul>
	 * @param $classes
	 * @param $args
	 *
	 * @return array
	 */
	function menu_submenu_classes($classes, $args): array {
		if ($args->theme_location == 'header') {
			$classes[] = 'dropdown-menu';
		}

		return $classes;
	}


	/**
	 * Make nav menus available in the REST API
	 *
	 * @return void
	 */
	function make_menus_available_in_rest(): void {
		// Route that gets the registered menu locations,
		// really just to check what they are from the API if needed
		register_rest_route('wp/v2', '/menus', array(
			'methods'             => 'GET',
			// if you're wondering where get_registered_nav_menus is, it's a built-in WP function
			'callback'            => 'get_registered_nav_menus',
			'permission_callback' => '__return_true'
		));

		// Route that gets a complete menu by location key (passed as a parameter to get_menu)
		register_rest_route('wp/v2', '/menu', array(
			'methods'             => 'GET',
			'callback'            => 'get_menu',
			'permission_callback' => '__return_true'
		));

		/**
		 * Inner callback function to get a menu by location key
		 * e.g., /wp-json/wp/v2/menu?location=header
		 * @param $data
		 *
		 * @return array|false
		 */
		function get_menu($data): bool|array {
			$location = $data->get_param('location');
			$locations = get_nav_menu_locations();
			$object = wp_get_nav_menu_object($locations[$location]);

			return wp_get_nav_menu_items($object->name);
		}

		/**
		 * Add classes to menu <li> tags
		 * @param $classes
		 * @param $item
		 * @param $args
		 * @param $depth
		 *
		 * @return array
		 * @noinspection PhpUnusedParameterInspection
		 */
		function menu_item_classes($classes, $item, $args, $depth): array {
			if ($args->theme_location == 'header-menu') {
				$classes[] = 'nav-item';

				if (in_array('menu-item-has-children', $classes)) {
					$classes[] = 'has-sub';
					$classes[] = 'toggle-hover';
				}
			}

			if ($args->theme_location == 'footer-menu') {
				if ($depth == 0 && $args->depth > 1) {
					$classes[] = 'menu-item--top-level col-xs-12 col-sm-6 col-xl-3';
				}
				else {
					if ($args->depth == 1) {
						$classes[] = 'col-xs-12';
					}
				}
			}

			return $classes;
		}
	}


	/**
	 * Get nav menu items by location
	 * @param $location string menu location name
	 * @param array $args args to pass to WordPress function wp_get_nav_menu_items
	 *
	 * @return false|array
	 */
	static function get_nav_menu_items_by_location(string $location, array $args = []): false|array {
		$locations = get_nav_menu_locations();

		if (isset($locations[$location])) {
			$object = wp_get_nav_menu_object($locations[$location]);
			$items = wp_get_nav_menu_items($object->name, $args);
			$current = get_queried_object();
			$default_category_id = get_option('default_category');

			foreach ($items as $item) {
				if (isset($current->post_type) && $current->post_type == 'page') {
					$post_id = $current->ID;
					if ($post_id == $item->object_id) {
						$item->classes[] = 'current-menu-item';
						$item->current = true;
					}
					if ($post_id == $item->post_parent) {
						$item->classes[] = 'current-menu-parent';
					}
				}
				else if (isset($current->taxonomy) && $current->taxonomy == 'category') {
					if ($item->object_id == PAGE_FOR_POSTS || $item->object_id == $default_category_id) {
						$item->classes[] = 'current-menu-item';
						$item->current = true;
					}
				}
				else if (isset($current->post_type) && $current->post_type == 'post') {
					if ($item->object_id == PAGE_FOR_POSTS || $item->object_id == $default_category_id) {
						$item->classes[] = 'current-menu-parent';
					}
				}
				else if (isset($current->post_type) && $item->type == 'post_type_archive') {
					if ($current->post_type == $item->object) {
						$item->classes[] = 'current-menu-parent';
					}
				}
				else if ($item->type == 'post_type_archive' && $current->name == $item->object) {
					$item->classes[] = 'current-menu-item';
					$item->current = true;
				}


				if ($item->url) {
					if (parse_url($item->url)['host'] !== parse_url(get_bloginfo('url'))['host']) {
						$item->classes[] = 'external';
					}
				}
			}

			return $items;
		}

		return [];
	}


	static function get_simplified_nav_menu_items_by_location(string $location) {
		$items = self::get_nav_menu_items_by_location($location);
		$result = array_reduce($items, function($acc, $item) {
			if($item->menu_item_parent > 0) {
				$acc[$item->menu_item_parent]['children'][] = [
					'title' => $item->title,
					'classes'    => array_filter($item->classes, fn($class) => !empty($class)),
					'link_attributes' => [
						'href'   => $item->url,
						'target' => $item->target,
						'title'  => $item->attr_title,
						'rel'    => $item->xfn,
						'classes' => [],
						'aria-current' => $item->current ? 'page' : null
					]
				];

				return $acc;
			}

			$acc[$item->ID] = [
				'title' => $item->title,
				'classes' => array_filter($item->classes, fn($class) => !empty($class)),
				'link_attributes' => [
					'href'   => $item->url,
					'target' => $item->target,
					'title'  => $item->attr_title,
					'rel'    => $item->xfn,
					'classes' => [],
					'aria-current' => $item->current ? 'page' : null
				],
				'children' => []
			];

			return $acc;
		}, []);

		// Reset array indexes before returning
		return array_values($result);
	}

}
