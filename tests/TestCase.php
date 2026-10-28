<?php
/**
 * Base test case.
 *
 * @package Salskea\Skeleton
 */

declare(strict_types=1);

namespace Salskea\Skeleton\Tests;

use Brain\Monkey;
use Mockery\Adapter\Phpunit\MockeryPHPUnitIntegration;

/**
 * Sets up Brain Monkey for each test. Escaping and translation functions are stubbed to behave
 * like WordPress; everything else is mocked in the test that needs it.
 */
abstract class TestCase extends \PHPUnit\Framework\TestCase {

	use MockeryPHPUnitIntegration;

	protected function setUp(): void {
		parent::setUp();
		Monkey\setUp();
		Monkey\Functions\stubEscapeFunctions();
		Monkey\Functions\stubTranslationFunctions();
	}

	protected function tearDown(): void {
		Monkey\tearDown();
		parent::tearDown();
	}
}
