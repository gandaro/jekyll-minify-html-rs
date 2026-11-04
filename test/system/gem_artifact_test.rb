# frozen_string_literal: true

# Copyright (C) 2026  Svend Gundestrup
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"
require "bundler"
require "rubygems/package"

# Verifies the packaged artifact, not just lib/ — catches spec.files glob
# gaps that lib-level tests can't see. Run via `rake test:system`.
class GemArtifactTest < Minitest::Test
  GEMSPEC = File.join(PROJECT_ROOT, "jekyll-minify-flow.gemspec")

  def setup
    @tmp = Dir.mktmpdir
    @gem_path = File.join(@tmp, "jekyll-minify-flow.gem")
    Dir.chdir(PROJECT_ROOT) do
      system("gem", "build", GEMSPEC, "--output", @gem_path, exception: true)
    end
  end

  def teardown
    FileUtils.remove_entry(@tmp)
  end

  def test_package_contents_and_metadata
    package_spec = Gem::Package.new(@gem_path).spec
    declared = Gem::Specification.load(GEMSPEC)

    assert_equal declared.version.to_s, package_spec.version.to_s
    assert_equal declared.required_ruby_version.to_s, package_spec.required_ruby_version.to_s
    %w[lib/jekyll-minify-flow.rb README.md LICENSE CHANGELOG.md].each do |file|
      assert_includes package_spec.files, file
    end
    %w[jekyll minify_html lightningcss].each do |dep|
      assert_includes package_spec.runtime_dependencies.map(&:name), dep
    end
  end

  def test_installed_gem_builds_a_jekyll_site
    installed = File.join(@tmp, "installed")
    Gem::Package.new(@gem_path).extract_files(installed)
    FileUtils.cp GEMSPEC, installed

    assert_path_exists File.join(installed, "lib", "jekyll-minify-flow.rb")

    site_dir = File.join(@tmp, "site")
    FileUtils.mkdir_p(site_dir)
    File.write(File.join(site_dir, "_config.yml"), "plugins:\n  - jekyll-minify-flow\n")
    File.write(File.join(site_dir, "index.html"), "---\n---\n<p>   spaced   </p>\n")
    File.write(File.join(site_dir, "main.css"), "body { color: #ff0000; }\n")
    File.write(File.join(site_dir, "Gemfile"), <<~RUBY)
      source "https://rubygems.org"
      gem "jekyll"
      gem "csv"
      gem "jekyll-minify-flow", path: "#{installed}"
    RUBY

    Bundler.with_unbundled_env do
      Dir.chdir(site_dir) do
        system({ "BUNDLE_GEMFILE" => File.join(site_dir, "Gemfile") },
               "bundle", "install", "--quiet", exception: true)
        system("bundle", "exec", "jekyll", "build", "--quiet", exception: true)
      end
    end

    assert_equal "<p>spaced", File.read(File.join(site_dir, "_site", "index.html"))
    assert_equal "body{color:red}", File.read(File.join(site_dir, "_site", "main.css"))
  end
end
