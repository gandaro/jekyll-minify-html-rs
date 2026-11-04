# frozen_string_literal: true

# Copyright (C) 2026  Svend Gundestrup
# SPDX-License-Identifier: AGPL-3.0-or-later

require "simplecov"
require "simplecov-cobertura" if ENV["CI"]

SimpleCov.start do
  enable_coverage :branch
  command_name ENV.fetch("COVERAGE_RUN", "Unit Tests")
  skip "/test/"
  minimum_coverage line: 98, branch: 90 if ENV["CI"] || ENV["COVERAGE"]
  if ENV["CI"]
    formatter SimpleCov::Formatter::MultiFormatter.new([
                                                         SimpleCov::Formatter::CoberturaFormatter,
                                                         SimpleCov::Formatter::JSONFormatter
                                                       ])
  end
end

require "jekyll"
require "jekyll-minify-flow"
require "jekyll_test_harness"
require "minitest/autorun"
require "fileutils"
require "tmpdir"

JekyllTestHarness.install!(framework: :minitest)

PROJECT_ROOT = File.expand_path("..", __dir__)

Dir.glob(File.expand_path("support/**/*.rb", __dir__), sort: true).each { |f| require f }

class JekyllMinifyFlowTest < Minitest::Test
  PAGE_HTML = <<~HTML
    ---
    ---
    <!DOCTYPE html>
    <html>
    <head>
    <style>
      body {
        color: red;
      }
    </style>
    </head>
    <body>
    <!-- keep me -->
    <script>
      function foo() {
        return 1;
      }
    </script>
    <p>   Hello   </p>
    </body>
    </html>
  HTML

  private

  # Builds a real site via jekyll-test-harness. index.html carries PAGE_HTML;
  # `files` merges extra source files and `config` merges into _config.yml.
  # Yields the scoped output-files handle for extra _site reads — the temp
  # tree is removed once jekyll_build returns, so all dest assertions must
  # run inside the block. Returns rendered index.html.
  def build_site(config = {}, files = {})
    index_html = nil
    jekyll_build(config: config, files: { "index.html" => PAGE_HTML }.merge(files)) do |site, output_files|
      index_html = output_files.read("index.html")
      yield site, output_files if block_given?
    end
    index_html
  end
end
