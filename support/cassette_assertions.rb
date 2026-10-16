# frozen_string_literal: true

require "json"
require "yaml"

module Multivitamin
  # Fixture inspection shared by scenario tests; no provider calls.
  module CassetteAssertions
    def cassette_interactions(directory, name)
      YAML.load_file(File.join(directory, "cassettes", "#{name}.yml")).fetch("http_interactions")
    end

    def cassette_requests(directory, name)
      cassette_interactions(directory, name).map do |interaction|
        JSON.parse(interaction.dig("request", "body", "string"))
      end
    end

    def assert_cassette_sanitized(directory, name, key:)
      cassette = File.binread(File.join(directory, "cassettes", "#{name}.yml"))
      refute_match(/sk-(?:or-v1-|ant-)?[A-Za-z0-9_\-]{8,}/, cassette)
      assert_includes cassette, "<#{key}>"
    end
  end
end
