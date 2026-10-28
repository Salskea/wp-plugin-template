<?php
/**
 * Plugin settings.
 *
 * @package Salskea\Skeleton
 */

declare(strict_types=1);

namespace Salskea\Skeleton;

/**
 * Settings stored in one wp_options row. A wp-config.php constant always overrides the stored
 * value, so secrets can be kept out of the database.
 */
class Settings {

	public const OPTION = 'salskea_skeleton_settings';

	public const DEFAULTS = [
		'api_url' => '',
		'api_key' => '',
	];

	/** Setting key => wp-config.php constant that overrides it. */
	private const CONSTANTS = [
		'api_key' => 'SALSKEA_SKELETON_API_KEY',
	];

	/**
	 * All settings, constants applied.
	 *
	 * @return array{api_url: string, api_key: string}
	 */
	public static function all(): array {
		$stored   = get_option( self::OPTION, [] );
		$settings = array_merge( self::DEFAULTS, is_array( $stored ) ? $stored : [] );

		foreach ( self::CONSTANTS as $key => $constant ) {
			if ( self::is_constant_defined( $key ) ) {
				$settings[ $key ] = constant( $constant );
			}
		}

		return [
			'api_url' => (string) $settings['api_url'],
			'api_key' => (string) $settings['api_key'],
		];
	}

	/**
	 * Whether the setting comes from a wp-config.php constant.
	 *
	 * @param string $key Setting key.
	 */
	public static function is_constant_defined( string $key ): bool {
		$constant = self::CONSTANTS[ $key ] ?? null;

		return null !== $constant && defined( $constant ) && '' !== constant( $constant );
	}

	/**
	 * Settings API sanitize callback. An empty secret keeps the stored one, so saving the form
	 * does not wipe it.
	 *
	 * @param mixed $input Raw form input.
	 * @return array{api_url: string, api_key: string}
	 */
	public static function sanitize( mixed $input ): array {
		$input  = is_array( $input ) ? $input : [];
		$stored = get_option( self::OPTION, [] );
		$stored = is_array( $stored ) ? $stored : [];

		$api_key = sanitize_text_field( (string) ( $input['api_key'] ?? '' ) );

		return [
			'api_url' => untrailingslashit( esc_url_raw( (string) ( $input['api_url'] ?? '' ) ) ),
			'api_key' => '' !== $api_key ? $api_key : (string) ( $stored['api_key'] ?? '' ),
		];
	}
}
