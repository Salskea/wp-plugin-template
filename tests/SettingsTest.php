<?php
/**
 * Settings tests.
 *
 * @package Salskea\Skeleton
 */

declare(strict_types=1);

namespace Salskea\Skeleton\Tests;

use Brain\Monkey\Functions;
use Salskea\Skeleton\Settings;

final class SettingsTest extends TestCase {

	public function test_all_merges_stored_values_over_defaults(): void {
		Functions\when( 'get_option' )->justReturn( [ 'api_url' => 'https://api.example.test' ] );

		$this->assertSame(
			[
				'api_url' => 'https://api.example.test',
				'api_key' => '',
			],
			Settings::all()
		);
	}

	public function test_all_survives_a_corrupted_option(): void {
		Functions\when( 'get_option' )->justReturn( 'not an array' );

		$this->assertSame( Settings::DEFAULTS, Settings::all() );
	}

	public function test_sanitize_cleans_url_and_key(): void {
		Functions\when( 'get_option' )->justReturn( [] );
		Functions\when( 'sanitize_text_field' )->alias( static fn( string $value ): string => trim( $value ) );
		Functions\when( 'untrailingslashit' )->alias( static fn( string $value ): string => rtrim( $value, '/\\' ) );

		$this->assertSame(
			[
				'api_url' => 'https://api.example.test',
				'api_key' => 'abc',
			],
			Settings::sanitize(
				[
					'api_url' => 'https://api.example.test/',
					'api_key' => ' abc ',
				]
			)
		);
	}

	public function test_sanitize_keeps_stored_key_when_field_is_empty(): void {
		Functions\when( 'get_option' )->justReturn( [ 'api_key' => 'secret' ] );
		Functions\when( 'sanitize_text_field' )->returnArg();
		Functions\when( 'untrailingslashit' )->returnArg();

		$this->assertSame( 'secret', Settings::sanitize( [ 'api_key' => '' ] )['api_key'] );
	}
}
