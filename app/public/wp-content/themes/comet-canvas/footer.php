<?php
use Doubleedesign\Comet\Core\{Menu, SiteFooter};
use Doubleedesign\CometCanvas\NavMenus;

$menuItems = NavMenus::get_simplified_nav_menu_items_by_location('footer');
$menuComponent = new Menu(['context' => 'site-footer'], $menuItems);
$footerComponent = new SiteFooter(['backgroundColor' => 'dark'], [$menuComponent]);
$footerComponent->render();

wp_footer(); ?>
</body>
</html>
