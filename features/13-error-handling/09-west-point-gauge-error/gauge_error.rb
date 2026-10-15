# frozen_string_literal: true

# Error handling · 09 · West Point gauge error
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

module WestPointGaugeError
  class GaugeHouseDark < StandardError
  end

  # The NOAA gauge at West Point, off Shilshole, is offline. Returning
  # the outage to the model lets the clerk tell the watch to leadline
  # the entrance. Raising from the lamp tool stops the desk instead.
  class WestPointGauge < RubyLLM::Tool
    description "Reads the NOAA tide gauge at West Point, Shilshole Bay"

    def self.tool_name
      "west_point_gauge"
    end

    def execute
      { error: "West Point gauge offline since 04:10. Leadline the Shilshole entrance." }
    end
  end

  class GaugeHouseLamp < RubyLLM::Tool
    description "Reads whether the West Point gauge-house lamp is lit"

    def self.tool_name
      "gauge_house_lamp"
    end

    def execute
      raise GaugeHouseDark, "The gauge-house lamp is out; the clerk will not read a dark board."
    end
  end

  class GaugeError
    INSTRUCTIONS = <<~TEXT.strip
      You are the tide clerk at West Point, Shilshole Bay.
      Call west_point_gauge once. Then answer in two short sentences.
      If the gauge is offline, tell the watch to leadline and quote 04:10.
      Do not invent a tide height.
    TEXT

    GAUGE_QUESTION = <<~TEXT.strip
      Morning watch at West Point, Thursday 15 October 2026.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9447130
      The seiner Cape Flattery is standing off the Shilshole entrance.
      What is the height on the West Point gauge?
    TEXT

    LAMP_QUESTION = "Is the gauge-house lamp lit?"

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
      chat.with_tools(WestPointGauge)
      chat.with_tool_options(choice: WestPointGauge)
      brief = chat.ask(GAUGE_QUESTION)
      tool_message = chat.messages.find { |message| message.role == :tool }

      lamp_error = nil
      lamp = open_chat
      lamp.with_tools(GaugeHouseLamp)
      lamp.with_tool_options(choice: GaugeHouseLamp)
      begin
        lamp.ask(LAMP_QUESTION)
      rescue GaugeHouseDark => raised
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
  Multivitamin::Cassettes.play(__dir__, "gauge_error") do
    result = WestPointGaugeError::GaugeError.conduct
  end

  puts result.brief
  puts result.tool_content
  puts result.lamp_error.class
end
