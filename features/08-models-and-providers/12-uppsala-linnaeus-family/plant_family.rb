# frozen_string_literal: true

# Models and providers · 12 · Uppsala Linnaeus family
#
# Teaches:
# - by_family matches the family field, not a substring of the id.
# - Ids that contain "sonnet" with another family stay off that list.
# - Models#find looks up an id. Enumerable#find is not available on that
#   object; walk all and then find.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"

module UppsalaLinnaeus
  # The herbarium clerk in Uppsala files clerks by family, the way the
  # Linnaean cabinet files genera, not by a name that merely contains
  # the word.
  class PlantFamily
    Result = Struct.new(
      :family_count,
      :family_name,
      :providers,
      :all_family_match,
      :substring_ids,
      :substring_outside_family,
      :anthropic_sample_id,
      :block_find_error,
      :block_find_message,
      keyword_init: true
    )

    def self.conduct
      configure

      family = RubyLLM.models.by_family("claude-sonnet")
      substring = RubyLLM.models.all.select { |model| model.id.include?("sonnet") }
      outside = substring.reject { |model| model.family == "claude-sonnet" }
      anthropic = family.all.find { |model| model.provider == "anthropic" }

      block_find_error = nil
      block_find_message = nil
      begin
        family.find { |model| model.provider == "anthropic" }
      rescue ArgumentError => error
        block_find_error = error.class.name
        block_find_message = error.message
      end

      Result.new(
        family_count: family.count,
        family_name: "claude-sonnet",
        providers: family.map(&:provider).uniq.sort,
        all_family_match: family.all? { |model| model.family == "claude-sonnet" },
        substring_ids: substring.map(&:id),
        substring_outside_family: outside.map { |model| [model.provider, model.id, model.family] },
        anthropic_sample_id: anthropic&.id,
        block_find_error: block_find_error,
        block_find_message: block_find_message
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.max_retries = 0
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "plant_family") do
    result = UppsalaLinnaeus::PlantFamily.conduct
  end

  puts "#{result.family_count} in family #{result.family_name}"
  puts "outside #{result.substring_outside_family.size}"
end
