<!--
Copyright (C) 2026  Svend Gundestrup
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# AGENTS.md — jekyll-minify-flow

Jekyll 4 plugin: HTML minification via the `minify_html` gem
(`[:pages, :documents] :post_render`) plus standalone CSS minification
via `lightningcss` (`:site, :post_write` at priority `:high` = 30,
ahead of Fingerprint Flow 11–19 and Compress Flow 0–10).

**Fork of [gandaro/jekyll-minify-html-rs](https://github.com/gandaro/jekyll-minify-html-rs)** (upstream inactive).

## Commands

```bash
bundle install
bundle exec rake test          # unit/integration suite (Minitest)
bundle exec rake test:system   # + builds & exercises the packaged .gem
bundle exec rake quick         # RuboCop + tests
bundle exec rake               # + bundler-audit
bundle exec rake ci            # full gate: tests + rubocop + gem build
```

## Conventions

- `# frozen_string_literal: true`, double quotes, RuboCop clean.
- Minitest (not RSpec): `test/test_helper.rb` carries SimpleCov —
  per-suite `command_name` ("Unit Tests"/"System Tests") so separate
  `Rake::TestTask` processes merge coverage instead of overwriting it.
  Coverage gate 98/90 on CI.
- `test/system/gem_artifact_test.rb` extracts the packaged `.gem` and
  runs a real `jekyll build` against it — catches `spec.files` gaps.
- Test Jekyll hooks via the public `Jekyll::Hooks.trigger`/`register`
  API — never `instance_variable_get(:@registry)`. There is no public
  unregister; deactivate probes with a captured `active` flag.
- `lib/jekyll_minify_flow/version.rb` is the single version literal;
  the gemspec `require_relative`s it.
- Gemfile: `gemspec` + dev/test deps in `group do` blocks (block for
  2+ gems in a group, inline `group:` for singletons). **No `ruby`
  directive** — the gem is tested on a version matrix; the support
  range lives in the gemspec's `required_ruby_version`.
- `.ruby-version` pins the dev interpreter (version managers only).

## Licensing — per-file SPDX headers are required

Dual-licensed fork: upstream code is MIT (`LICENSE.MIT`), fork work is
AGPL-3.0-or-later (`LICENSE`). Every file must carry its provenance:

| Provenance | Header |
| --- | --- |
| Unmodified upstream file | `Copyright (C) 2025  gandaro` + `SPDX-License-Identifier: MIT` |
| Modified upstream file | both copyright lines + `SPDX-License-Identifier: MIT AND AGPL-3.0-or-later` |
| New fork file | `Copyright (C) 2026  Svend Gundestrup` + `SPDX-License-Identifier: AGPL-3.0-or-later` |

Comment style: `#` for Ruby/YAML/dotfiles (after the
`frozen_string_literal` line where present), `<!-- -->` for Markdown.
Exempt: `LICENSE`/`LICENSE.MIT` (they are the license texts),
`.ruby-version` and `Gemfile.lock` (machine-read/generated).
When editing a file, keep its header accurate to its provenance —
a first fork edit to a pristine upstream file upgrades it to dual.

## Gotchas

- `required_ruby_version` is capped `< 3.5.dev` because `minify_html`
  0.18.1 declares `Ruby < 3.5.dev` and ships no Ruby 4.0 native binary
  (upstream PR wilsonzlin/minify-html#278). Do not add a Ruby 4 CI leg
  or widen the cap until that lands.
- CSS minification runs at site `post_write` priority `:high` — keep it
  ahead of fingerprint/compress flows so those see minified bytes.
- `minify_css` (top-level map) configures standalone CSS files;
  `minify_html.minify_css` configures inline CSS inside HTML — they are
  separate switches.
