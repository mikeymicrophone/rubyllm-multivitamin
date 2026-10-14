# frozen_string_literal: true

# Image generation · 10 · Bremerton dry dock gate cost
#
# Teaches:
# - Image#tokens.input and tokens.output are filled from usage.
# - Image#cost.total is nil when the registry has no image price and the
#   response omits usage.cost.
# - That is not the same as a free chat model's cost of 0.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module BremertonDryDockGateCost
  # The dry dock clerk at Bremerton wants a plate of the gate with a ship
  # on the sill, then records the token counts on the work order.
  class GateCost
    PROMPT = <<~TEXT.strip
      Dry dock gate at Puget Sound Naval Shipyard, Bremerton, with a frigate on the sill.
      Sill marks wet, caisson chain taut, 14 October 2026 morning flood.
      Documentary engineering plate. No crew on the wall.
    TEXT

    Result = Struct.new(
      :input_tokens,
      :output_tokens,
      :cost_total,
      :cost_input,
      :cost_output,
      keyword_init: true
    )

    def self.conduct
      configure
      image = RubyLLM.paint(PROMPT, **Multivitamin::Models.image_paint)

      Result.new(
        input_tokens: image.tokens.input,
        output_tokens: image.tokens.output,
        cost_total: image.cost.total,
        cost_input: image.cost.input,
        cost_output: image.cost.output
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 180
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "gate_cost") do
    result = BremertonDryDockGateCost::GateCost.conduct
  end

  puts "tokens #{result.input_tokens}/#{result.output_tokens} cost #{result.cost_total.inspect}"
end
