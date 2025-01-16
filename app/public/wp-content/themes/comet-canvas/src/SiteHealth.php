<?php
namespace Doubleedesign\CometCanvas;

class SiteHealth {
	public function __construct() {
		add_filter('site_status_tests', [$this, 'required_plugins_site_health'], 20, 1);
	}

	static function required_plugins_status(): array {
		$successes = array();
		$errors = array();
		$warnings = array();
		$theme = wp_get_theme();
		$parent_theme = wp_get_theme($theme->get('Template'));

		if($theme->get('TextDomain') === 'comet' || $parent_theme->get('TextDomain') === 'comet') {
			$required = [
				//'advanced-custom-fields-pro/acf.php' => 'Advanced Custom Fields Pro',
				'doublee-breadcrumbs/breadcrumbs.php' => 'Double-E Breadcrumbs',
				'comet-components-wp/comet.php' => 'Comet Components',
			];
			$recommended = [
				//'tinymce-advanced/tinymce-advanced.php' => 'Advanced Editor Tools',
				'doublee-base-plugin/doublee.php' => 'Double-E Design Base Plugin',
			];
		}
		else {
			return array(
				'successes' => $successes,
				'errors'    => $errors,
				'warnings'  => $warnings
			);
		}

		foreach($required as $plugin => $name) {
			if(!is_plugin_active($plugin)) {
				$errors[] = $name;
			}
			else {
				$successes[] = $name;
			}
		}

		foreach($recommended as $plugin => $name) {
			if(!is_plugin_active($plugin)) {
				$warnings[] = $name;
			}
			else {
				$successes[] = $name;
			}
		}

		return array(
			'successes' => $successes,
			'errors'    => $errors,
			'warnings'  => $warnings
		);
	}

	function required_plugins_site_health($tests): array {
		$tests['direct']['doublee_required_plugins'] = array(
			'label' => __('Required plugins'),
			'test'  => [$this, 'site_health_plugin_check_required'],
		);

		$tests['direct']['doublee_recommended_plugins'] = array(
			'label' => __('Recommended plugins'),
			'test'  => [$this, 'site_health_plugin_check_recommended'],
		);

		$tests['direct']['doublee_installed_theme_plugins'] = array(
			'label' => __('Required and recommended plugins'),
			'test'  => [$this, 'site_health_plugin_check_correct'],
		);

		return $tests;
	}

	function site_health_plugin_check_required(): array {
		$status = SiteHealth::required_plugins_status();

		if ($status['errors']) {
			$required = implode(', ', $status['errors']);
			return array(
				'label'       => __('Required plugins'),
				'status'      => 'critical',
				'badge'       => array(
					'label' => __('Performance'),
					'color' => 'blue',
				),
				'description' => sprintf(
					'<p>%s</p>',
					__("The following plugins to be installed and activated for full functionality: $required. Without them, some features may be missing or not work as expected.")
				),
				'test'        => 'doublee_required_plugins'
			);
		}

		return array();
	}

	function site_health_plugin_check_recommended(): array {
		$status = SiteHealth::required_plugins_status();

		if ($status['warnings']) {
			$recommended = implode(', ', $status['warnings']);
			return array(
				'label'       => __('Recommended plugins'),
				'status'      => 'recommended',
				'badge'       => array(
					'label' => __('Performance'),
					'color' => 'blue',
				),
				'description' => sprintf(
					'<p>%s</p>',
					__("The following plugins are strongly recommended to be installed and activated for full functionality: $recommended. Without them, some features may be missing or not work as expected.")
				),
				'test'        => 'doublee_recommended_plugins'
			);
		}

		return array();
	}

	function site_health_plugin_check_correct(): array {
		$status = SiteHealth::required_plugins_status();

		if ($status['successes']) {
			$successes = implode(', ', $status['successes']);
			return array(
				'label'       => __('Required and recommended plugins'),
				'status'      => 'good',
				'badge'       => array(
					'label' => __('Performance'),
					'color' => 'blue',
				),
				'description' => sprintf(
					'<p>%s</p>',
					__("The following required and recommended plugins for your theme are installed and activated: $successes.")
				),
				'test'        => 'doublee_installed_theme_plugins'
			);
		}

		return array();
	}
}
