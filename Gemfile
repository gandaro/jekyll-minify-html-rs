# frozen_string_literal: true

# Copyright (C) 2025  gandaro
# Copyright (C) 2026  Svend Gundestrup
# SPDX-License-Identifier: MIT AND AGPL-3.0-or-later

source "https://rubygems.org"

gemspec

group :development, :test do
  gem "bundler-audit", "~> 0.9"
  gem "csv" # jekyll needs it explicitly on Ruby >= 3.4 (removed from stdlib)
  gem "minitest", "~> 6.0"
  gem "rake", "~> 13.2"
  gem "tmpdir"
end

group :development do
  gem "rubocop", "~> 1.91"
  gem "rubocop-minitest", "~> 0.41"
end

group :test do
  gem "jekyll-test-harness", "= 0.1.0.alpha"
  gem "simplecov", "~> 1.1"
  gem "simplecov-cobertura", "~> 4.0"
end
