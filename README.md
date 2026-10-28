# Salskean WordPress-lisäosapohja

Kaikkien Salskean WordPress-lisäosien yhteinen pohja: sama rakenne, samat tarkistukset ja sama
julkaisuputki jokaisessa lisäosassa. Pohja on itsessään toimiva lisäosa (`salskea-skeleton`),
jonka tarkistukset ajetaan CI:ssä, joten pohja ei pääse rapistumaan.

## Uusi lisäosa

```bash
gh repo create Salskea/<slug> --private --template Salskea/wp-plugin-template --clone
cd <slug>
./scripts/init.sh <slug> "<Lisäosan nimi>" '<Vendor>\<Nimi>'
composer check
git add -A && git commit -m "feat: initial plugin structure" && git push
```

Esimerkki: `./scripts/init.sh acme-events "Acme Events" 'Acme\Events'`.

`init.sh` nimeää pääfilen ja tyylitiedoston uudelleen, vaihtaa kaikki pohjan nimet (nimiavaruus,
vakio- ja optioetuliite, text domain, Composer-paketti), korvaa tämän README:n ja CHANGELOGin
lisäosan omilla ja poistaa itsensä. Johdetut nimet:

| Mistä | Esimerkki |
|---|---|
| slug | `acme-events` (hakemisto, pääfile, text domain, CSS-luokat) |
| vakioetuliite | `ACME_EVENTS_` (`ACME_EVENTS_VERSION`, `ACME_EVENTS_API_KEY`) |
| optio- ja hook-etuliite | `acme_events_` |
| Composer-paketti | `acme/acme-events` |

Ensimmäinen push `main`-haaraan luo CI:ssä tagin `v1.0.0` ja GitHub Releasen. Älä pushaa tagia
itse ensimmäisellä kerralla.

## Rakenne

```
<slug>.php                 header, vakiot, luokkien rekisteröinti plugins_loaded-hookissa
uninstall.php              poistaa lisäosan tiedot
includes/class-*.php       yksi vastuu per luokka, namespace <Vendor>\<Nimi>, composer classmap
assets/                    CSS/JS, rekisteröidään ja ladataan vain tarvittaessa
tests/                     PHPUnit 11 + Brain Monkey
scripts/                   release.sh, build-zip.sh, check-version.sh, lib.sh
.github/workflows/         ci.yml, release.yml
composer.json / .lock      lock committoidaan
phpcs.xml.dist             koodityyli ja tietoturvasäännöt
phpstan.neon.dist          staattinen analyysi, taso 8
```

Tavallisia luokkia: `Settings`, `Admin_Page`, `Shortcode`, `<Lähde>_API`, `Sync`, `Cron`, `CLI`.
Pohjassa on mukana kolme ensimmäistä esimerkkeinä.

## Käytännöt

**Koodityyli.** WordPress Coding Standards (WordPress-Extra) ja lisäksi syötteen
sanitointisäännöt. Sisennys tabeilla, lyhyt taulukkosyntaksi `[]` sallittu, Yoda-ehdot vapaaehtoisia.
Kaikki globaalit (funktiot, hookit, optiot, vakiot) alkavat lisäosan etuliitteellä; PHPCS
tarkistaa tämän. `composer lint:fix` korjaa suurimman osan automaattisesti.

**Tyypit.** `declare(strict_types=1)` joka tiedostossa, parametri- ja paluutyypit kaikkialla.
PHPStan tasolla 8 WordPress-laajennuksella.

**Tietoturva.** Nämä PHPCS tarkistaa:

- Kaikki tuloste escapetaan tulostushetkellä (`esc_html`, `esc_attr`, `esc_url`, `wp_kses_post`).
- Kaikki syöte (`$_POST`, `$_GET`, …) validoidaan, `wp_unslash`-käsitellään ja sanitoidaan.
- Lomakkeissa nonce ja `current_user_can`. Asetussivut Settings API:lla, joka hoitaa molemmat.

Lisäksi:

- Salaisuudet eivät koskaan koodiin. `wp-config.php`-vakio ohittaa aina hallintasivulla
  tallennetun arvon (ks. `Settings`).
- Ulkoiset rajapinnat: avaimet otsakkeessa (esim. Basic auth), ei URL-parametreina.
- Ajastetut ajot: WP-Cron-hook ja asiakaskohtainen `<ASIAKAS>_DISABLE_CRON`-vakio, jolloin ajo
  tehdään palvelimen cronista WP-CLI-komennolla.

**Header.** `Requires PHP: 8.2`, `Requires at least: 6.5` ja `Update URI: false`. Viimeinen estää
WordPressiä tarjoamasta wordpress.orgin samannimisen lisäosan "päivitystä". Jos lisäosa tarvitsee
toisen lisäosan, lisää `Requires Plugins: woocommerce` (slugit pilkulla eroteltuna).

**Käännökset.** Käyttöliittymätekstit kirjoitetaan suomeksi `__()`/`esc_html_e()`-funktioihin
lisäosan text domainilla. Käännöstiedostoja ei tehdä ennen kuin niitä tarvitaan.

**Testit.** Puhdas logiikka (normalisointi, renderöinti, URL-rakennus, sanitointi) erotetaan
WordPress-kytkennästä ja testataan. WordPress-funktiot mockataan testikohtaisesti Brain
Monkeylla (`Functions\when()`, `Functions\expect()`); escape- ja käännösfunktiot on valmiiksi
stubattu `tests/TestCase.php`:ssa. Oikeaa rajapintadataa `tests/fixtures/`-kansioon.

**Riippumattomuus `vendor/`-hakemistosta.** Jos `vendor/autoload.php` puuttuu, pääfile näyttää
ylläpitäjälle virheilmoituksen eikä kaada sivustoa.

## Kehitys

```bash
composer install
composer check        # lint + analyse + test, sama kuin CI
composer lint:fix     # phpcbf
```

Paikallinen testisivusto (Valet, `~/Projektit/wp-sites/<site>`):

```bash
ln -sfn "$PWD" ~/Projektit/wp-sites/<site>/wp-content/plugins/<slug>
wp plugin activate <slug> --path=$HOME/Projektit/wp-sites/<site>
```

## Versiointi ja julkaisu

SemVer. Commit-viestit conventional-muodossa: `fix:` → patch, `feat:` → minor, `feat!:` tai
`BREAKING CHANGE` → major.

Versio on kolmessa paikassa: pääfilen `Version:`-header, `<PREFIX>_VERSION`-vakio ja
`CHANGELOG.md`:n uusin julkaisu. `scripts/check-version.sh` tarkistaa, että ne täsmäävät, ja CI
ajaa sen joka pushissa.

1. Jokainen muutos kirjataan samassa commitissa `CHANGELOG.md`:n `## [Unreleased]`-osioon
   (Lisätty / Muutettu / Korjattu / Poistettu).
2. `./scripts/release.sh` ehdottaa versiota commiteista, muuttaa `[Unreleased]`-osion uudeksi
   versioksi, päivittää headerin ja vakion, ajaa `composer check`, committoi, tagaa ja pushaa
   vahvistuksen jälkeen.
3. CI:n `release.yml` tarkistaa version tagia vasten, ajaa tarkistukset, rakentaa zipin
   (`scripts/build-zip.sh`) ja luo GitHub Releasen, jonka teksti on CHANGELOGin osio.

Jos versio nostetaan käsin ja pushataan `main`iin ilman tagia, CI luo tagin ja käynnistää
julkaisun itse.

Tuotantozip `<slug>-vX.Y.Z.zip` sisältää vain pääfilen, `uninstall.php`:n, `includes/`, `assets/`,
`languages/` (jos on), `vendor/` ilman dev-riippuvuuksia, `README.md`:n ja `CHANGELOG.md`:n.
`./scripts/build-zip.sh` tekee saman paikallisesti hakemistoon `dist/`.

## CI

`ci.yml` ajaa joka pushissa ja PR:ssä PHP 8.2-, 8.3- ja 8.4-versioilla: `composer validate`,
PHPCS, PHPStan, PHPUnit ja versiotarkistuksen. `main`-haarassa uusi versio luo tagin.
Lockfile ratkaistaan PHP 8.2:lle (`config.platform.php`), joten sama lock toimii kaikilla.

## Olemassa olevan lisäosan siirto pohjaan

1. Kopioi pohjasta `phpcs.xml.dist`, `phpstan.neon.dist`, `phpunit.xml.dist`, `scripts/`
   (paitsi `init*`), `.github/workflows/` ja `tests/TestCase.php` + `tests/constants.php`.
   Vaihda konfiguraatioiden etuliitteet, text domain ja nimiavaruus lisäosan omiksi.
2. `composer.json`: poista `"version"`, kopioi pohjasta `require-dev`, `config` ja `scripts`,
   aja `composer update`.
3. Pääfile: header-rivit (`Requires at least`, `Update URI`, tarvittaessa `Requires Plugins`) ja
   `vendor/`-tarkistus pohjan mallin mukaan.
4. `composer lint:fix`, sitten loput PHPCS-löydökset käsin. Tietoturvalöydöksiä ei ohiteta.
5. PHPStan: korjaa löydökset tai, jos niitä on paljon, `vendor/bin/phpstan analyse
   --generate-baseline` ja korjaa baselinea pienemmäksi myöhemmin.
6. Testit: korvaa `tests/bootstrap.php`:n käsin kirjoitetut WP-stubit Brain Monkeylla.
7. Poista README:n `**Versio:**`-rivi ja lisää CHANGELOGin alkuun `## [Unreleased]`.
8. Kirjaa siirto CHANGELOGiin (`### Muutettu`) ja julkaise uutena versiona.

## Pohjan oma kehitys

Tämä repo on GitHubin template-repo. Sen CI ajaa samat tarkistukset, mutta ei tee tageja,
julkaisuja eikä versiotarkistusta (ehto `github.repository` workfloweissa), koska pohjan oma
`CHANGELOG.md` kuvaa pohjan muutoksia, ei esimerkkilisäosan. `scripts/init/` sisältää README:n
ja CHANGELOGin, jotka `init.sh` siirtää uuden lisäosan juureen.
