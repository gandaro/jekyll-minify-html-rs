# frozen_string_literal: true

# Copyright (C) 2025  gandaro
# Copyright (C) 2026  Svend Gundestrup
# SPDX-License-Identifier: MIT AND AGPL-3.0-or-later

require_relative "lib/jekyll_minify_flow/version"

Gem::Specification.new do |s|
  s.name        = "jekyll-minify-flow"
  s.version     = JekyllMinifyFlow::VERSION
  s.summary     = "HTML, CSS and JavaScript minifier for Jekyll"
  # NOTE: rubygems.org renders the description through RDoc::Markup only
  # when it starts with an == heading at column 0 — keep the heredoc
  # content flush-left or the page renders as one plain <p>.
  s.description = <<~DESC
    == HTML, CSS and JS minification for Jekyll

    Minifies rendered HTML pages and documents with the minify-html Rust
    crate — inline CSS and JS included — plus standalone .css files with
    Lightning CSS at post_write, ahead of fingerprint and compression
    plugins.
  DESC
  s.authors     = %w[gandaro gundestrup]
  s.homepage    = "https://github.com/gundestrup/jekyll-minify-flow"
  s.licenses    = ["MIT", "AGPL-3.0-or-later"]
  s.metadata    = {
    "source_code_uri" => "https://github.com/gundestrup/jekyll-minify-flow",
    "changelog_uri" => "https://github.com/gundestrup/jekyll-minify-flow/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/gundestrup/jekyll-minify-flow/issues",
    "rubygems_mfa_required" => "true"
  }

  s.required_ruby_version = ">= 3.3.0", "< 3.5.dev"
  s.files = Dir["lib/**/*", "README.md", "LICENSE", "LICENSE.MIT", "CHANGELOG.md"]

  s.add_dependency "jekyll", ">= 4.4", "< 5.0"
  s.add_dependency "lightningcss", "~> 1.33"
  s.add_dependency "minify_html", "~> 0.18.1"
  s.add_dependency "oxc", "~> 0.156"
end
