<?php
/**
 * Removes the plugin's data when the plugin is deleted.
 *
 * @package Salskea\Skeleton
 */

declare(strict_types=1);

if ( ! defined( 'WP_UNINSTALL_PLUGIN' ) ) {
	exit;
}

if ( ! is_readable( __DIR__ . '/vendor/autoload.php' ) ) {
	return;
}

require_once __DIR__ . '/vendor/autoload.php';

delete_option( Salskea\Skeleton\Settings::OPTION );
