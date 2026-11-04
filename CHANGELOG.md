<!--
Copyright (C) 2025  gandaro
Copyright (C) 2026  Svend Gundestrup
SPDX-License-Identifier: MIT AND AGPL-3.0-or-later
-->

# Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2026-10-21

First release as **`jekyll-minify-flow`** — a fork of
[gandaro/jekyll-minify-html-rs](https://github.com/gandaro/jekyll-minify-html-rs)
(upstream inactive since August 2026). The original code remains MIT
(`LICENSE.MIT`); all fork work is AGPL-3.0-or-later (`LICENSE`), with
per-file SPDX provenance headers.

### Added

- Standalone CSS minification via the `lightningcss` gem: every `.css` file
  written to the destination — static files and `.scss` sources compiled by
  Jekyll — is minified at site `post_write` with priority `:high`, ahead of
  Fingerprint Flow (12) and Compress Flow (10). A new `minify_css` map in
  `_config.yml` exposes `enabled`, `minify`, `error_recovery`, `targets`,
  `css_modules` and `scope`; invalid values fail the build, and parse errors
  name the offending file.
- `_config.yml` configuration: a `minify_html` map is read from the site
  config and merged over the defaults, so every `minify-html` `Cfg` option is
  adjustable — previously the options were hardcoded. Unknown option names,
  non-boolean values and non-map config fail the build descriptively.
- Minitest suite building real Jekyll sites in tmpdirs, plus a
  `test/system/` suite that builds the `.gem` artifact, verifies packaged
  files and metadata via `Gem::Package`, and runs a real `jekyll build`
  against the extracted package — catches `spec.files` gaps. Rebuild
  idempotency is covered.
- Fleet tooling: Dependabot (bundler + github-actions), tag-triggered
  `release.yml` publishing via OIDC trusted publishing, `semgrep ci` job,
  SonarQube Cloud scan, Codecov (`codecov.yml`), local `.semgrep.yml`,
  `version:bump`/`release_tag` rake tasks, `.devin/wiki.json`, README
  badges, `AGENTS.md`.

### Changed

- Renamed the project/gem to `jekyll-minify-flow` (gemspec, lib entry
  point, `JekyllMinifyFlow` module, packaged files, docs). Configuration
  keys `minify_html`/`minify_css` are unchanged.
- Relicensed: new work is AGPL-3.0-or-later, original code stays MIT;
  gemspec `license` and packaged file list updated.
- Test suite migrated from RSpec to Minitest (`test/`); `rubocop-rspec`
  replaced with `rubocop-minitest`. SimpleCov merges per-suite coverage
  (unit + system); 98/90 coverage gate on CI.
- `required_ruby_version` capped at `< 3.5.dev` — `minify_html` 0.18.1
  declares `Ruby < 3.5.dev` and ships no Ruby 4.0 native binary
  (wilsonzlin/minify-html#278). The cap makes the constraint explicit and
  can be lifted once upstream ships Ruby 4.0 support.
- Tests exercise hooks via the public `Jekyll::Hooks.trigger`/`register`
  API instead of `@registry` internals; probes deactivate via flag since
  Jekyll has no public unregister.
- gemspec declares the `jekyll` runtime dependency (`>= 4.4, < 5.0`) —
  the plugin calls `Jekyll::Hooks` at load time.

---

_Releases below are from upstream
[gandaro/jekyll-minify-html-rs](https://github.com/gandaro/jekyll-minify-html-rs)
under the MIT License; version numbering restarts with the fork._

## [1.0.0] - 2025-10-28

### Added

- Initial release: `:post_render` hook on `[:pages, :documents]` minifying
  `.html` output with `minify-html` (hardcoded `minify_css`/`minify_js`
  enabled).
