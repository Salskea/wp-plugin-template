<?php
/**
 * Settings page.
 *
 * @package Salskea\Skeleton
 */

declare(strict_types=1);

namespace Salskea\Skeleton;

/**
 * Settings → Salskea Skeleton, built on the Settings API (nonce and capability handled by core).
 */
class Admin_Page {

	private const SLUG = 'salskea-skeleton';

	private const CAPABILITY = 'manage_options';

	/**
	 * Hook into WordPress.
	 */
	public function register(): void {
		add_action( 'admin_menu', [ $this, 'add_menu' ] );
		add_action( 'admin_init', [ $this, 'register_setting' ] );
	}

	/**
	 * Add the page under Settings.
	 */
	public function add_menu(): void {
		add_options_page(
			__( 'Salskea Skeleton', 'salskea-skeleton' ),
			__( 'Salskea Skeleton', 'salskea-skeleton' ),
			self::CAPABILITY,
			self::SLUG,
			[ $this, 'render' ]
		);
	}

	/**
	 * Register the option and its sanitizer.
	 */
	public function register_setting(): void {
		register_setting(
			self::SLUG,
			Settings::OPTION,
			[
				'type'              => 'array',
				'sanitize_callback' => [ Settings::class, 'sanitize' ],
				'default'           => Settings::DEFAULTS,
			]
		);
	}

	/**
	 * Render the page.
	 */
	public function render(): void {
		if ( ! current_user_can( self::CAPABILITY ) ) {
			return;
		}

		$settings = Settings::all();
		$name     = Settings::OPTION;
		?>
		<div class="wrap">
			<h1><?php echo esc_html( get_admin_page_title() ); ?></h1>
			<form method="post" action="options.php">
				<?php settings_fields( self::SLUG ); ?>
				<table class="form-table" role="presentation">
					<tr>
						<th scope="row"><label for="salskea-skeleton-api-url"><?php esc_html_e( 'Rajapinnan osoite', 'salskea-skeleton' ); ?></label></th>
						<td><input type="url" class="regular-text" id="salskea-skeleton-api-url" name="<?php echo esc_attr( $name ); ?>[api_url]" value="<?php echo esc_attr( $settings['api_url'] ); ?>"></td>
					</tr>
					<tr>
						<th scope="row"><label for="salskea-skeleton-api-key"><?php esc_html_e( 'API-avain', 'salskea-skeleton' ); ?></label></th>
						<td>
							<?php if ( Settings::is_constant_defined( 'api_key' ) ) : ?>
								<p><?php esc_html_e( 'Määritelty wp-config.php:ssä.', 'salskea-skeleton' ); ?></p>
							<?php else : ?>
								<input type="password" class="regular-text" autocomplete="off" id="salskea-skeleton-api-key" name="<?php echo esc_attr( $name ); ?>[api_key]" value=""
									placeholder="<?php echo '' !== $settings['api_key'] ? esc_attr__( 'Tallennettu, jätä tyhjäksi säilyttääksesi', 'salskea-skeleton' ) : ''; ?>">
							<?php endif; ?>
						</td>
					</tr>
				</table>
				<?php submit_button(); ?>
			</form>
		</div>
		<?php
	}
}
