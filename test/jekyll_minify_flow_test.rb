# frozen_string_literal: true

# Copyright (C) 2026  Svend Gundestrup
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class MinifyHtmlTest < JekyllMinifyFlowTest
  def test_minifies_pages_and_documents_at_post_render
    site = Struct.new(:config).new({})
    doc_class = Struct.new(:output, :site) do
      def output_ext = ".html"
    end

    %i[pages documents].each do |container|
      doc = doc_class.new("<p>   spaced   </p>", site)
      Jekyll::Hooks.trigger(container, :post_render, doc)

      assert_equal "<p>spaced", doc.output
    end
  end

  def test_defaults_to_css_and_javascript_minification
    assert_equal({ minify_css: true, minify_js: true }, JekyllMinifyFlow::DEFAULT_OPTIONS)
  end

  def test_minifies_html_css_and_javascript_with_default_options
    output = build_site

    assert_includes output, "body{color:red}"
    assert_includes output, "function foo(){return 1}"
    refute_includes output, "<!-- keep me -->"
    refute_includes output, "   Hello"
  end

  def test_keeps_comments_when_keep_comments_is_enabled
    output = build_site("minify_html" => { "keep_comments" => true })

    assert_includes output, "<!-- keep me -->"
  end

  def test_leaves_javascript_untouched_when_minify_js_is_disabled
    output = build_site("minify_html" => { "minify_js" => false })

    assert_includes output, "return 1;"
    assert_includes output, "body{color:red}"
  end

  def test_leaves_inline_css_untouched_when_minify_css_is_disabled
    output = build_site("minify_html" => { "minify_css" => false })

    assert_includes output, "color: red;"
    assert_includes output, "function foo(){return 1}"
  end

  def test_reads_options_from_config_yml_and_supports_other_cfg_options
    output = build_site("minify_html" => { "keep_closing_tags" => true, "minify_js" => false })

    assert_includes output, "<p>Hello</p>"
    assert_includes output, "return 1;"
  end

  def test_rejects_a_non_hash_minify_html_config
    error = assert_raises(JekyllTestHarness::SiteBuildError) { build_site("minify_html" => true) }
    assert_match(/minify_html must be a map/, error.message)
  end

  def test_rejects_unknown_minify_html_options
    error = assert_raises(JekyllTestHarness::SiteBuildError) do
      build_site("minify_html" => { "minfy_js" => false })
    end
    assert_match(/minfy_js/, error.message)
  end

  def test_rejects_non_boolean_minify_html_values
    error = assert_raises(JekyllTestHarness::SiteBuildError) do
      build_site("minify_html" => { "keep_comments" => "false" })
    end
    assert_match(/keep_comments must be true or false/, error.message)
  end

  def test_leaves_static_html_files_unchanged
    static_html = "<p>   Static   </p><!-- keep me -->"

    build_site({}, "static.html" => static_html) do |_site, output_files|
      assert_equal static_html, output_files.read("static.html")
    end
  end

  def test_minifies_before_site_post_write_hooks
    active = true
    snapshots = []
    [12, 10].each do |priority|
      Jekyll::Hooks.register(:site, :post_write, priority: priority) do |site|
        snapshots << [priority, File.read(File.join(site.dest, "index.html"))] if active
      end
    end

    build_site

    assert_equal [12, 10], snapshots.map(&:first)
    snapshots.each do |(_, html)|
      assert_includes html, "body{color:red}"
      assert_includes html, "function foo(){return 1}"
      refute_includes html, "<!-- keep me -->"
    end
  ensure
    # hooks can't be unregistered, so the probes deactivate instead
    active = false
  end

  def test_skips_non_html_output
    feed = <<~XML
      ---
      ---
      <feed>
        <!-- comment -->
        <x>   spaced   </x>
      </feed>
    XML
    build_site({}, "feed.xml" => feed) do |_site, output_files|
      xml = output_files.read("feed.xml")

      assert_includes xml, "<!-- comment -->"
      assert_includes xml, "   spaced   "
    end
  end

  def test_minifies_documents_not_just_pages
    post = <<~MD
      ---
      ---
      <p>   spaced   </p>
    MD
    build_site({}, "_posts" => { "2026-01-01-test.md" => post }) do |_site, output_files|
      assert_includes output_files.read("2026/01/01/test.html"), "<p>spaced"
    end
  end

  def test_minifies_pages_rendered_through_a_layout
    layout = <<~HTML
      <html>
        <body>
          {{ content }}
          <!-- layout comment -->
        </body>
      </html>
    HTML
    files = {
      "_layouts" => { "default.html" => layout },
      "index.html" => "---\nlayout: default\n---\n<p>   spaced   </p>\n"
    }
    output = build_site({}, files)

    assert_includes output, "<p>spaced"
    refute_includes output, "layout comment"
  end

  def test_minifies_html_pulled_in_from_an_include
    files = {
      "_includes" => { "chunk.html" => "<span>   chunk   </span><!-- include comment -->" },
      "index.html" => "---\n---\n<div>{% include chunk.html %}</div>\n"
    }
    output = build_site({}, files)

    assert_includes output, "<span> chunk </span>"
    refute_includes output, "include comment"
  end
end

class MinifyCssTest < JekyllMinifyFlowTest
  def test_minifies_standalone_css_files_after_site_write
    build_site({}, "main.css" => "body {\n  color: #ff0000;\n}\n") do |_site, output_files|
      assert_equal "body{color:red}", output_files.read("main.css")
    end
  end

  def test_minifies_css_produced_from_scss_pages
    build_site({}, "main.scss" => "---\n---\nbody { color: #ff0000; }\n") do |_site, output_files|
      assert_equal "body{color:red}", output_files.read("main.css")
    end
  end

  def test_leaves_css_files_untouched_when_minify_css_enabled_is_false
    css = "body {\n  color: #ff0000;\n}\n"

    build_site({ "minify_css" => { "enabled" => false } }, "main.css" => css) do |_site, output_files|
      assert_equal css, output_files.read("main.css")
    end
  end

  def test_lowers_css_syntax_for_configured_browser_targets
    targets = { "safari" => 15, "chrome" => 90.5, "firefox" => "100" }

    build_site(
      { "minify_css" => { "targets" => targets } },
      "main.css" => ".a { color: oklch(60% .2 30) }\n"
    ) do |_site, output_files|
      assert_equal ".a{color:#de3e2d;color:lab(51.6908% 61.9679 48.0969)}", output_files.read("main.css")
    end
  end

  def test_scopes_every_rule_when_minify_css_scope_is_set
    build_site(
      { "minify_css" => { "scope" => "[data-x]" } },
      "main.css" => ".card { color: red }\n"
    ) do |_site, output_files|
      assert_equal ".card[data-x]{color:red}", output_files.read("main.css")
    end
  end

  def test_renames_class_names_when_minify_css_css_modules_is_enabled
    build_site(
      { "minify_css" => { "css_modules" => { "pattern" => "scoped-[local]" } } },
      "main.css" => ".card { color: red }\n"
    ) do |_site, output_files|
      assert_includes output_files.read("main.css"), ".scoped-card{color:red}"
    end
  end

  def test_fails_the_build_on_unparseable_css_by_default
    error = assert_raises(JekyllTestHarness::SiteBuildError) { build_site({}, "main.css" => "a { !!! }\n") }
    assert_match(/minify_css failed.*main\.css/, error.message)
  end

  def test_recovers_past_bad_rules_when_minify_css_error_recovery_is_enabled
    build_site(
      { "minify_css" => { "error_recovery" => true } },
      "main.css" => "a { !!! }\nb { color: red }\n"
    ) do |_site, output_files|
      assert_equal "b{color:red}", output_files.read("main.css")
    end
  end

  def test_minifies_css_before_fingerprint_priority_post_write_hooks
    active = true
    snapshot = nil
    Jekyll::Hooks.register(:site, :post_write, priority: 12) do |site|
      snapshot = File.read(File.join(site.dest, "main.css")) if active
    end

    build_site({}, "main.css" => "body { color: red; }\n")

    assert_equal "body{color:red}", snapshot
  ensure
    # hooks can't be unregistered, so the probe deactivates instead
    active = false
  end

  def test_rejects_a_non_hash_minify_css_config
    error = assert_raises(JekyllTestHarness::SiteBuildError) { build_site("minify_css" => true) }
    assert_match(/minify_css must be a map/, error.message)
  end

  def test_rejects_unknown_minify_css_options
    error = assert_raises(JekyllTestHarness::SiteBuildError) do
      build_site("minify_css" => { "minfiy" => true })
    end
    assert_match(/minfiy/, error.message)
  end

  def test_rejects_invalid_minify_css_option_values
    error = assert_raises(JekyllTestHarness::SiteBuildError) do
      build_site("minify_css" => { "scope" => 5 })
    end
    assert_match(/minify_css\.scope has invalid value/, error.message)

    error = assert_raises(JekyllTestHarness::SiteBuildError) do
      build_site("minify_css" => { "targets" => "safari" })
    end
    assert_match(/minify_css\.targets has invalid value/, error.message)

    error = assert_raises(JekyllTestHarness::SiteBuildError) do
      build_site("minify_css" => { "css_modules" => "yes" })
    end
    assert_match(/minify_css\.css_modules has invalid value/, error.message)
  end

  def test_rebuilding_the_same_site_stays_minified
    files = { "main.css" => "body { color: red; }\n" }
    first = build_site({}, files)
    second = build_site({}, files) do |_site, output_files|
      assert_equal "body{color:red}", output_files.read("main.css")
    end

    assert_equal first, second
    assert_includes second, "body{color:red}"
  end
end
