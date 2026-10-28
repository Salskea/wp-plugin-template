# Salskea Skeleton

Salskean WordPress-lisäosapohja.

## Asennus

1. Lataa uusin `salskea-skeleton-vX.Y.Z.zip` repon GitHub Releaseista.
2. WordPress: *Lisäosat → Lisää uusi → Lataa lisäosa*, tai pura zip hakemistoon
   `wp-content/plugins/`.
3. Aktivoi lisäosa.

### Asetukset

*Asetukset → Salskea Skeleton*. API-avaimen voi antaa myös `wp-config.php`:ssä, jolloin se
ohittaa hallintasivun arvon:

```php
define( 'SALSKEA_SKELETON_API_KEY', '...' );
```

## Käyttö

```
[salskea_skeleton otsikko="Hei"]
```

## Kehitys

```bash
composer install
composer check        # PHPCS + PHPStan + PHPUnit, sama kuin CI
composer lint:fix     # korjaa koodityylin automaattisesti
```

Paikallinen testisivusto:

```bash
ln -sfn "$PWD" ~/Projektit/wp-sites/<site>/wp-content/plugins/salskea-skeleton
wp plugin activate salskea-skeleton --path=$HOME/Projektit/wp-sites/<site>
```

### Rakenne

| Polku | Sisältö |
|---|---|
| `salskea-skeleton.php` | Header, vakiot, luokkien rekisteröinti |
| `includes/class-settings.php` | Asetukset (`wp_options` + `wp-config.php`-vakiot) |
| `includes/class-admin-page.php` | Asetussivu |
| `includes/class-shortcode.php` | `[salskea_skeleton]` |
| `uninstall.php` | Poistaa lisäosan tiedot, kun lisäosa poistetaan |
| `tests/` | PHPUnit + Brain Monkey |

## Versiointi ja julkaisu

Muutokset kirjataan kehityksen aikana `CHANGELOG.md`:n `[Unreleased]`-osioon. Julkaisu:

```bash
./scripts/release.sh
```

CI rakentaa zipin ja GitHub Releasen. Käytännöt ja koko julkaisuputki:
[Salskea/wp-plugin-template](https://github.com/Salskea/wp-plugin-template).
