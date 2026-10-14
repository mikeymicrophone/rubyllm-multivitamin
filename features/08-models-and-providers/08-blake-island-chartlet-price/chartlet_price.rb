# frozen_string_literal: true

# Models and providers · 08 · Blake Island chartlet price
#
# Teaches:
# - image_models lists paint clerks.
# - price(:input) is nil or a Numeric, never an error, for a known model.
# - An unknown price kind raises ArgumentError.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"

module BlakeIslandParkBoat
  # The park boat off Blake Island looks up the paint clerk who can draw a
  # chartlet of Tillicum Village's landing, then reads the posted input
  # price instead of guessing from the brochure.
  class ChartletPrice
    Result = Struct.new(
      :image_count,
      :input_kinds,
      :flash_id,
      :flash_provider,
      :flash_family,
      :flash_type,
      :flash_input,
      :flash_output,
      :unknown_kind_error,
      :unknown_kind_message,
      keyword_init: true
    )

    def self.conduct
      configure

      images = RubyLLM.models.image_models
      input_kinds = images.map { |model| model.price(:input) }
      flash = RubyLLM.models.find("gemini-2.5-flash-image")

      unknown_error = nil
      unknown_message = nil
      begin
        flash.price(:banana)
      rescue ArgumentError => error
        unknown_error = error.class.name
        unknown_message = error.message
      end

      Result.new(
        image_count: images.count,
        input_kinds: input_kinds,
        flash_id: flash.id,
        flash_provider: flash.provider,
        flash_family: flash.family,
        flash_type: flash.type,
        flash_input: flash.price(:input),
        flash_output: flash.price(:output),
        unknown_kind_error: unknown_error,
        unknown_kind_message: unknown_message
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
  Multivitamin::Cassettes.play(__dir__, "chartlet_price") do
    result = BlakeIslandParkBoat::ChartletPrice.conduct
  end

  puts "#{result.flash_provider} #{result.flash_id} input=#{result.flash_input} output=#{result.flash_output}"
  puts result.unknown_kind_message
end
