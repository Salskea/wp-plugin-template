<?php
/**
 * Shortcode tests.
 *
 * @package Salskea\Skeleton
 */

declare(strict_types=1);

namespace Salskea\Skeleton\Tests;

use Brain\Monkey\Functions;
use Salskea\Skeleton\Shortcode;

final class ShortcodeTest extends TestCase {

	public function test_render_escapes_title(): void {
		$this->assertSame(
			'<p class="salskea-skeleton">&lt;script&gt;</p>',
			Shortcode::render( '<script>' )
		);
	}

	public function test_render_outputs_nothing_for_blank_title(): void {
		$this->assertSame( '', Shortcode::render( '  ' ) );
	}

	public function test_handle_enqueues_style_and_accepts_empty_attributes(): void {
		Functions\when( 'shortcode_atts' )->alias( static fn( array $defaults, array $atts ): array => array_merge( $defaults, $atts ) );
		Functions\expect( 'wp_enqueue_style' )->once()->with( 'salskea-skeleton' );

		$this->assertSame( '', ( new Shortcode() )->handle( '' ) );
	}
}
