# frozen_string_literal: true

# Copyright (C) 2025  gandaro
# Copyright (C) 2026  Svend Gundestrup
# SPDX-License-Identifier: MIT AND AGPL-3.0-or-later

require "jekyll"
require "lightningcss"
require "minify_html"
require_relative "jekyll_minify_flow/version"

module JekyllMinifyFlow
  DEFAULT_OPTIONS = { minify_css: true, minify_js: true }.freeze
  OPTION_NAMES = %w[
    allow_noncompliant_unquoted_attribute_values allow_optimal_entities
    allow_removing_spaces_between_attributes keep_closing_tags keep_comments
    keep_html_and_head_opening_tags keep_input_type_text_attr keep_ssi_comments
    minify_css minify_doctype minify_js preserve_brace_template_syntax
    preserve_chevron_percent_template_syntax remove_bangs remove_processing_instructions
  ].freeze

  DEFAULT_CSS_OPTIONS = { enabled: true, minify: true }.freeze
  CSS_OPTION_NAMES = %w[enabled minify error_recovery targets css_modules scope].freeze

  def self.options_for(site)
    configured = site.config.fetch("minify_html", {})
    raise Jekyll::Errors::FatalException, "minify_html must be a map of options" unless configured.is_a?(Hash)

    configured.each_with_object(DEFAULT_OPTIONS.dup) do |(key, value), options|
      name = key.to_s
      raise Jekyll::Errors::FatalException, "unknown minify_html option: #{name}" unless OPTION_NAMES.include?(name)
      unless [true, false].include?(value)
        raise Jekyll::Errors::FatalException, "minify_html.#{name} must be true or false"
      end

      options[name.to_sym] = value
    end
  end

  def self.css_options_for(site)
    configured = site.config.fetch("minify_css", {})
    raise Jekyll::Errors::FatalException, "minify_css must be a map of options" unless configured.is_a?(Hash)

    configured.each_with_object(DEFAULT_CSS_OPTIONS.dup) do |(key, value), options|
      name = key.to_s
      raise Jekyll::Errors::FatalException, "unknown minify_css option: #{name}" unless CSS_OPTION_NAMES.include?(name)
      unless valid_css_option?(name, value)
        raise Jekyll::Errors::FatalException, "minify_css.#{name} has invalid value: #{value.inspect}"
      end

      options[name.to_sym] = value
    end
  end

  def self.valid_css_option?(name, value)
    case name
    when "enabled", "minify", "error_recovery" then [true, false].include?(value)
    when "scope" then value.is_a?(String)
    when "css_modules" then [true, false].include?(value) || value.is_a?(Hash)
    when "targets" then valid_targets?(value)
    end
  end

  def self.valid_targets?(value)
    value.is_a?(Hash) && value.values.all? { |v| v.is_a?(Integer) || v.is_a?(Float) || v.is_a?(String) }
  end

  def self.minify_css_files(site)
    options = css_options_for(site)
    return unless options.delete(:enabled)

    Dir.glob(File.join(site.dest, "**/*.css")).each do |path|
      result = LightningCSS.transform(File.read(path), filename: path, **options)
      File.write(path, result.code)
    rescue LightningCSS::Error => e
      raise Jekyll::Errors::FatalException, "minify_css failed: #{e.message}"
    end
  end
end

Jekyll::Hooks.register [:pages, :documents], :post_render do |doc|
  next unless doc.output_ext == ".html"

  doc.output = minify_html(doc.output, JekyllMinifyFlow.options_for(doc.site))
end

Jekyll::Hooks.register :site, :post_write, priority: :high do |site|
  JekyllMinifyFlow.minify_css_files(site)
end
