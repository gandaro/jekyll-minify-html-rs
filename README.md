<!--
Copyright (C) 2025  gandaro
Copyright (C) 2026  Svend Gundestrup
SPDX-License-Identifier: MIT AND AGPL-3.0-or-later
-->

# jekyll-minify-flow

[![Status: Active](https://img.shields.io/badge/status-active-success)](https://github.com/gundestrup/jekyll-minify-flow)
[![CI](https://github.com/gundestrup/jekyll-minify-flow/actions/workflows/ci.yml/badge.svg)](https://github.com/gundestrup/jekyll-minify-flow/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/tag/gundestrup/jekyll-minify-flow)](https://github.com/gundestrup/jekyll-minify-flow/tags)
[![Gem Version](https://img.shields.io/gem/v/jekyll-minify-flow)](https://rubygems.org/gems/jekyll-minify-flow)
[![Codecov](https://codecov.io/gh/gundestrup/jekyll-minify-flow/graph/badge.svg)](https://codecov.io/gh/gundestrup/jekyll-minify-flow)
[![Ruby](https://img.shields.io/badge/ruby-%E2%89%A5%203.3-red.svg)](https://www.ruby-lang.org/)
[![Jekyll](https://img.shields.io/badge/jekyll-4.x-blue.svg)](https://jekyllrb.com/)
[![License: AGPL v3](https://img.shields.io/badge/license-AGPL--3.0--or--later-blue.svg)](LICENSE)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/gundestrup/jekyll-minify-flow)
[![CodeFactor](https://www.codefactor.io/repository/github/gundestrup/jekyll-minify-flow/badge)](https://www.codefactor.io/repository/github/gundestrup/jekyll-minify-flow)
[![Semgrep CE](https://img.shields.io/badge/Semgrep_CE-security-success)](https://github.com/gundestrup/jekyll-minify-flow/security/code-scanning)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=gundestrup_jekyll-minify-flow&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=gundestrup_jekyll-minify-flow)

This Jekyll plugin uses [minify-html](https://crates.io/crates/minify-html) to minify rendered HTML pages and documents, and [Lightning CSS](https://lightningcss.dev) to minify standalone `.css` files. Static HTML files without front matter are copied unchanged by Jekyll.

## Installation

```rb
gem "jekyll-minify-flow", "~> 1.1.0"
```

Add `jekyll-minify-flow` to the `plugins` list in `_config.yml`:

```yaml
plugins:
  - jekyll-minify-flow
```

## Configuration

By default the plugin minifies HTML with inline CSS and JavaScript
minification enabled. Options can be adjusted by adding a `minify_html`
map to `_config.yml`; any option set there overrides the defaults. Option names must match the table below and values must be YAML booleans (`true` or `false`); invalid configuration stops the build:

```yaml
minify_html:
  minify_css: true
  minify_js: true
  keep_comments: false
```

All [Cfg](https://docs.rs/minify-html/0.18.1/minify_html/struct.Cfg.html)
options of the pinned `minify-html` 0.18.1 release are supported:

| Option | Default | Description |
|--------|---------|-------------|
| `minify_css` | `true` | Minify CSS in `<style>` tags and `style` attributes |
| `minify_js` | `true` | Minify JavaScript in `<script>` tags |
| `keep_closing_tags` | `false` | Do not omit closing tags when possible |
| `keep_comments` | `false` | Keep all comments |
| `keep_html_and_head_opening_tags` | `false` | Do not omit `<html>` and `<head>` opening tags |
| `keep_input_type_text_attr` | `false` | Keep `type=text` attribute name and value on `<input>` elements |
| `keep_ssi_comments` | `false` | Keep SSI comments |
| `minify_doctype` | `false` | Minify DOCTYPEs (may not be spec compliant) |
| `preserve_brace_template_syntax` | `false` | Pass `{{ }}`, `{# #}`, `{% %}` template code through untouched |
| `preserve_chevron_percent_template_syntax` | `false` | Pass `<% %>` template code through untouched |
| `remove_bangs` | `false` | Remove all bangs |
| `remove_processing_instructions` | `false` | Remove all processing instructions |
| `allow_noncompliant_unquoted_attribute_values` | `false` | Allow unquoted attribute values prohibited by the WHATWG spec |
| `allow_optimal_entities` | `false` | Allow entity minifications that may not pass validation |
| `allow_removing_spaces_between_attributes` | `false` | Allow removing spaces between attributes when possible |

### Standalone CSS

Every `.css` file Jekyll writes to the destination — static files as well as
`.scss` sources Jekyll compiled — is minified with Lightning CSS after the site
is written. A `minify_css` map in `_config.yml` adjusts the behavior (this map
is separate from `minify_html.minify_css`, which only covers CSS embedded in
HTML):

```yaml
minify_css:
  enabled: true
  error_recovery: false
  targets:
    safari: 15.4
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enabled` | `bool` | `true` | Minify standalone `.css` files |
| `minify` | `bool` | `true` | Print output as small as it goes |
| `error_recovery` | `bool` | `false` | Carry on past rules that cannot be parsed, instead of failing the build |
| `targets` | `map` | unset | Browser → oldest supported version (`Integer` for majors, `Float`/`String` for minor versions); unsupported syntax is lowered |
| `css_modules` | `bool` or `map` | unset | Compile as a CSS module, optionally with a `pattern` |
| `scope` | `String` | unset | Selector fragment to narrow every rule by |

`filename` is always set to the file being processed so errors and warnings
name the right source. Unparseable CSS fails the build with a
`FatalException` naming the file unless `error_recovery` is enabled.

The plugin runs at page/document `post_render`, and the CSS pass at site
`post_write` with priority `:high`, so both run before site `post_write`
hooks such as Fingerprint Flow (priority 12) and Compress Flow (priority 10).
Fingerprinting therefore sees rendered, minified HTML and CSS; compression
runs after URL rewriting. Jekyll 4.4+ and Ruby 3.3+ are the supported
versions.

## Development

```bash
bundle install
bundle exec rake test          # unit/integration suite (Minitest)
bundle exec rake test:system   # + builds & exercises the packaged gem
bundle exec rake quick         # RuboCop + tests
bundle exec rake               # + bundler-audit
```

The tests build real Jekyll sites in tmpdirs and assert on the minified
output. `test/system/` additionally builds the `.gem` artifact, checks its
metadata and packaged file list with `Gem::Package`, and runs a full
`jekyll build` against the extracted package contents — it catches
`spec.files` gaps that lib-level tests cannot see.

## Licensing

This project is a fork of
[gandaro/jekyll-minify-html-rs](https://github.com/gandaro/jekyll-minify-html-rs).
The original code is licensed under the MIT License (see
[LICENSE.MIT](LICENSE.MIT)). All new modifications, features, and bug
fixes added in this fork are licensed under the GNU Affero General
Public License v3.0 or later (see [LICENSE](LICENSE)).
