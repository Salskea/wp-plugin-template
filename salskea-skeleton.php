<?php
/**
 * Plugin Name:       Salskea Skeleton
 * Description:       Salskean WordPress-lisäosapohja.
 * Version:           1.0.0
 * Author:            Salskea Oy
 * Author URI:        https://www.salskea.fi/
 * Text Domain:       salskea-skeleton
 * Requires at least: 6.5
 * Requires PHP:      8.2
 * Update URI:        false
 *
 * @package Salskea\Skeleton
 */

declare(strict_types=1);

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

// A missing vendor/ (e.g. a symlinked dev checkout without composer install) must not take the site down.
if ( ! is_readable( __DIR__ . '/vendor/autoload.php' ) ) {
	add_action(
		'admin_notices',
		static function (): void {
			echo '<div class="notice notice-error"><p>';
			echo esc_html__( 'Salskea Skeleton: vendor/autoload.php puuttuu. Aja composer install.', 'salskea-skeleton' );
			echo '</p></div>';
		}
	);
	return;
}

require_once __DIR__ . '/vendor/autoload.php';

define( 'SALSKEA_SKELETON_VERSION', '1.0.0' );
define( 'SALSKEA_SKELETON_URL', plugin_dir_url( __FILE__ ) );

use Salskea\Skeleton\Admin_Page;
use Salskea\Skeleton\Shortcode;

add_action(
	'plugins_loaded',
	static function (): void {
		( new Shortcode() )->register();

		if ( is_admin() ) {
			( new Admin_Page() )->register();
		}
	}
);
