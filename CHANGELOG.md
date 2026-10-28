# Muutosloki

Pohjan muutokset. Muoto perustuu [Keep a Changelogiin](https://keepachangelog.com/fi/1.1.0/).

## [Unreleased]

## [2.0.1] - 2026-10-28

### Korjattu

- PHPCS ei enää estä testejä lukemasta `tests/fixtures/`-tiedostoja (`file_get_contents`):
  `WordPress.WP.AlternativeFunctions` ohitetaan `tests/`-hakemistossa.

## [2.0.0] - 2026-10-28

### Muutettu

- Pohja kirjoitettu kokonaan uudelleen Salskean lisäosamallin mukaiseksi: namespace ja composer
  classmap, yksi vastuu per luokka `includes/`-hakemistossa, esimerkkiluokat `Settings`,
  `Admin_Page` ja `Shortcode`.
- Versio kolmessa paikassa (header, vakio, CHANGELOG); muutokset kirjataan `[Unreleased]`-osioon,
  josta `scripts/release.sh` tekee julkaisun.
- Slug luetaan pääfilestä; workflowt ja skriptit eivät sisällä lisäosan nimeä.

### Lisätty

- `scripts/init.sh` uuden lisäosan alustukseen.
- Dev-riippuvuudet: PHPUnit 11, Brain Monkey (WP-funktioiden mockaus), PHP_CodeSniffer +
  WordPress Coding Standards (`phpcs.xml.dist`), PHPStan + phpstan-wordpress (`phpstan.neon.dist`,
  taso 8).
- CI: PHP 8.2–8.4 -matriisi, PHPCS, PHPStan, PHPUnit ja versiotarkistus joka pushissa;
  automaattinen tagi ja GitHub Release.
- Headeriin `Update URI: false` ja `Requires at least: 6.5`; pääfile ei kaada sivustoa, jos
  `vendor/` puuttuu.

### Poistettu

- Vanha boilerplate (loader-, i18n-, activator- ja deactivator-luokat, `admin/`, `public/`,
  `languages/`), `VERSION`-tiedosto, `version-bump.sh` ja `setup.sh`.
- Forgejo-workflowt (`.forgejo/`).

## [0.1.0] - 2026-04-10

### Lisätty

- Ensimmäinen versio (WordPress Plugin Boilerplate -pohjainen).
