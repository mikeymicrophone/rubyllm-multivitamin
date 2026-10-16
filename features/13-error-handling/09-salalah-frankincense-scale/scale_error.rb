# frozen_string_literal: true

# Error handling · 09 · Salalah frankincense scale
#
# Teaches:
# - A tool that returns { error: } sends that Hash back to the model.
#   The model continues and writes a brief.
# - A tool that raises stops the chat. The exception is for the
#   application, not for the model.

require "json"
require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SalalahFrankincenseScale
  class ScaleHouseDark < StandardError
  end

  # The beam-scale in a Salalah frankincense loft is offline. Returning
  # the outage to the model lets the clerk tell the sorter to weigh the
  # Hojari lot on the hand-beam. Raising from the lamp tool stops the
  # desk instead.
  class SalalahBeamScale < RubyLLM::Tool
    description "Reads the beam-scale in a Salalah frankincense loft"

    def self.tool_name
      "salalah_beam_scale"
    end

    def execute
      { error: "Salalah beam-scale offline since 04:10. Weigh the Hojari lot on the hand-beam." }
    end
  end

  class ScaleHouseLamp < RubyLLM::Tool
    description "Reads whether the Salalah scale-house lamp is lit"

    def self.tool_name
      "scale_house_lamp"
    end

    def execute
      raise ScaleHouseDark, "The scale-house lamp is out; the clerk will not read a dark board."
    end
  end

  class ScaleError
    INSTRUCTIONS = <<~TEXT.strip
      You are the loft clerk in a Salalah frankincense warehouse.
      Call salalah_beam_scale once. Then answer in two short sentences.
      If the scale is offline, tell the sorter to use the hand-beam and quote 04:10.
      Do not invent a lot weight.
    TEXT

    GAUGE_QUESTION = <<~TEXT.strip
      Morning watch in Salalah, Friday 16 October 2026.
      Land of Frankincense: https://whc.unesco.org/en/list/1010.
      Sorter Layla is holding a Hojari lot at the loft door.
      What is the weight on the Salalah beam-scale?
    TEXT

    LAMP_QUESTION = "Is the scale-house lamp lit?"

    Result = Struct.new(
      :brief,
      :tool_content,
      :roles,
      :lamp_error,
      :lamp_is_llm_error,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_tools(SalalahBeamScale)
      chat.with_tool_options(choice: SalalahBeamScale)
      brief = chat.ask(GAUGE_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      lamp_error = nil
      lamp = open_chat
      lamp.with_tools(ScaleHouseLamp)
      lamp.with_tool_options(choice: ScaleHouseLamp)
      begin
        lamp.ask(LAMP_QUESTION)
      rescue ScaleHouseDark => raised
        lamp_error = raised
      end

      Result.new(
        brief: brief.content,
        tool_content: tool_message&.content,
        roles: chat.messages.map(&:role),
        lamp_error: lamp_error,
        lamp_is_llm_error: lamp_error.is_a?(RubyLLM::Error)
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 90
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "scale_error") do
    result = SalalahFrankincenseScale::ScaleError.conduct
  end

  puts result.brief
  puts result.tool_content
  puts result.lamp_error.class
end
