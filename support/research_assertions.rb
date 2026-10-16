# frozen_string_literal: true

require "yaml"
require "json"
require "base64"
require "minitest/mock"

module Multivitamin
  # HTTP-shape and credential checks shared by the hosted-research scaffolding.
  module ResearchAssertions
    def interactions
      YAML.load_file(self.class::CASSETTE).fetch("http_interactions")
    end

    def requests
      interactions.map do |interaction|
        body = interaction.dig("request", "body", "string").to_s
        body.empty? ? {} : JSON.parse(body)
      end
    end

    def assert_research_credentials_filtered
      cassette = File.binread(self.class::CASSETTE)
      refute_match(/sk-(?:or-v1-|proj-)?[A-Za-z0-9_-]{8,}/, cassette)
      refute_match(/ya29\.[A-Za-z0-9_-]+|BEGIN (?:RSA )?PRIVATE KEY/, cassette)
      assert_includes cassette, "<VERTEXAI_ACCESS_TOKEN>"
      interactions.each do |interaction|
        assert_match(%r{\Ahttps://aiplatform\.googleapis\.com/v1beta1/projects/}, interaction.dig("request", "uri"))
      end
    end
  end
end
