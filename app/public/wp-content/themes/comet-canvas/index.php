<?php
use Doubleedesign\Comet\Core\PageHeader;
get_header();

if(!is_front_page()) {
	if(class_exists("Doubleedesign\Breadcrumbs\Breadcrumbs")) {
		$breadcrumbs = Doubleedesign\Breadcrumbs\Breadcrumbs::$instance->get_raw_breadcrumbs();
		$pageHeader = new PageHeader(['backgroundColor' => 'white', 'size' => 'narrow'], get_the_title(), $breadcrumbs);
	}
	else {
		$pageHeader = new PageHeader(['backgroundColor' => 'white', 'size' => 'narrow'], get_the_title());
	}

	$pageHeader->render();
}

the_content();
get_footer();
