<?php
/**
 * Example shortcode.
 *
 * @package Salskea\Skeleton
 */

declare(strict_types=1);

namespace Salskea\Skeleton;

/**
 * [salskea_skeleton otsikko="..."] — renders a heading. Shows the pattern: thin WordPress glue in
 * handle(), pure and testable output in render().
 */
class Shortcode {

	public const TAG = 'salskea_skeleton';

	private const STYLE_HANDLE = 'salskea-skeleton';

	/**
	 * Hook into WordPress.
	 */
	public function register(): void {
		add_shortcode( self::TAG, [ $this, 'handle' ] );
		add_action( 'wp_enqueue_scripts', [ $this, 'register_style' ] );
	}

	/**
	 * Register (not enqueue) the stylesheet; it loads only on pages that use the shortcode.
	 */
	public function register_style(): void {
		wp_register_style( self::STYLE_HANDLE, SALSKEA_SKELETON_URL . 'assets/salskea-skeleton.css', [], SALSKEA_SKELETON_VERSION );
	}

	/**
	 * Shortcode callback.
	 *
	 * @param array<string, string>|string $atts Shortcode attributes; WordPress passes '' when there are none.
	 */
	public function handle( array|string $atts ): string {
		$atts = shortcode_atts( [ 'otsikko' => '' ], is_array( $atts ) ? $atts : [], self::TAG );

		wp_enqueue_style( self::STYLE_HANDLE );

		return self::render( (string) $atts['otsikko'] );
	}

	/**
	 * Escaped HTML for the given title.
	 *
	 * @param string $title Title text.
	 */
	public static function render( string $title ): string {
		if ( '' === trim( $title ) ) {
			return '';
		}

		return sprintf( '<p class="salskea-skeleton">%s</p>', esc_html( $title ) );
	}
}
