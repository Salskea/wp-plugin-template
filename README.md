# WordPress Plugin Template

Reusable starter template for WordPress plugins with multi-platform CI/CD (GitHub + Forgejo).

## Starting a New Plugin

### 1. Clone or fork this template

**GitHub** — use the "Use this template" button, or:
```bash
git clone git@github.com:Salskea/wp-plugin-template.git my-plugin-name
cd my-plugin-name
```

**Forgejo:**
```bash
git clone git@git.kuhnia.fi:<your-username>/wp-plugin-template.git my-plugin-name
cd my-plugin-name
```

### 2. Run setup

```bash
./setup.sh "My Plugin Name" "my-plugin-name" "MY_PLUGIN_NAME"
```

This renames all template placeholders throughout the codebase and removes `setup.sh` when done.

| Argument | Example | Replaces |
|---|---|---|
| `"My Plugin Name"` | Human-readable title | `Plugin Name Here` |
| `"my-plugin-name"` | Slug (lowercase, hyphens) | `plugin-name` |
| `"MY_PLUGIN_NAME"` | Constant prefix (uppercase, underscores) | `PLUGIN_NAME` |

### 3. Update plugin metadata

Open `my-plugin-name.php` and fill in:
- `Plugin URI` — your plugin's URL
- `Description` — what the plugin does
- `Author` and `Author URI`

### 4. Connect to git remote and push

```bash
# Point to your new repo (create it first on GitHub or Forgejo)
git remote set-url origin git@github.com:<your-username>/my-plugin-name.git

git add -A && git commit -m "feat: initial plugin setup"
git push -u origin main
```

### 5. (Forgejo only) Add RELEASE_TOKEN secret

In your Forgejo repo: **Settings → Secrets → Add secret**
- Name: `RELEASE_TOKEN`
- Value: a Forgejo personal access token with `write:release` scope

Create a token at: `https://git.kuhnia.fi/user/settings/applications`

GitHub repos need no setup — `GITHUB_TOKEN` is used automatically.

---

## Releasing a New Version

Use the `/release` Claude Code command:

```
/release
```

Claude will:
1. Analyze git commits since the last tag
2. Propose a semver bump (patch / minor / major) and draft a changelog entry
3. Wait for your confirmation
4. Update all version locations, commit, tag, and push

CI/CD then automatically:
1. Validates version sync across all files
2. Builds a distributable `.zip` (dev files excluded)
3. Creates a GitHub or Forgejo Release with changelog as release notes and the zip attached

### Manual alternative

```bash
./version-bump.sh 1.1.0 minor
```

---

## CI/CD Overview

| Trigger | GitHub | Forgejo |
|---|---|---|
| Push to `main` | `.github/workflows/ci.yml` | `.forgejo/workflows/ci.yml` |
| Push `v*` tag | `.github/workflows/release.yml` | `.forgejo/workflows/release.yml` |

**CI checks (both platforms):**
- PHP syntax check on all `.php` files
- Version sync: `VERSION` file, plugin header `Version:`, version constant, and class fallback must all match

**Release workflow additionally:**
- Tag version must match `VERSION` file
- `CHANGELOG.md` must have a `## [X.Y.Z]` entry for the version
- Builds zip excluding: `.git`, `.github`, `.forgejo`, `.claude`, `docs`, `*.sh`, `CHANGELOG.md`, `VERSION`, `CLAUDE.md`
- Creates a release with the zip attached and the CHANGELOG section as release notes

---

## File Structure

```
my-plugin-name/
├── .github/workflows/          # GitHub Actions
│   ├── ci.yml                  # Runs on push/PR to main
│   └── release.yml             # Runs on v* tag push
├── .forgejo/workflows/         # Forgejo Actions (identical logic)
│   ├── ci.yml
│   └── release.yml
├── admin/
│   ├── class-my-plugin-name-admin.php
│   ├── css/my-plugin-name-admin.css
│   ├── js/my-plugin-name-admin.js
│   └── partials/my-plugin-name-admin-display.php
├── includes/
│   ├── class-my-plugin-name.php           # Main orchestrator
│   ├── class-my-plugin-name-loader.php    # WordPress hook registry
│   ├── class-my-plugin-name-i18n.php      # i18n loader
│   ├── class-my-plugin-name-activator.php
│   └── class-my-plugin-name-deactivator.php
├── languages/
│   └── my-plugin-name.pot
├── public/
│   ├── class-my-plugin-name-public.php
│   ├── css/my-plugin-name-public.css
│   ├── js/my-plugin-name-public.js
│   └── partials/my-plugin-name-public-display.php
├── my-plugin-name.php          # Main plugin file (WordPress header)
├── index.php                   # Security file
├── uninstall.php               # Uninstall handler
├── VERSION                     # Single source of truth for version number
├── CHANGELOG.md                # Keep a Changelog format
└── version-bump.sh             # Interactive version bumper (manual alternative to /release)
```
