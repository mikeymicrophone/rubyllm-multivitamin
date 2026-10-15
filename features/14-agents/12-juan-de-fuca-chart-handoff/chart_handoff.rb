# frozen_string_literal: true

# Agents · 12 · Juan de Fuca chart handoff
#
# Teaches:
# - Two agents can share one chat. The specialist wraps clerk.chat.
# - The buoy clerk sees the chart correction without repeating the notice.
# - New instructions from the second agent go on the same transcript.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module JuanDeFucaChartHandoff
  class ChartClerk < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    temperature 0.2

    instructions <<~TEXT.strip
      You are the chart clerk for the Strait of Juan de Fuca.
      Answer in two short sentences from the correction only.
      Name buoy 2 and the 270-degree bearing.
      Do not invent a depth.
    TEXT
  end

  class BuoyClerk < RubyLLM::Agent
    temperature 0.2

    instructions <<~TEXT.strip
      You are the buoy clerk who posts Ediz Hook tickets from a chart correction.
      Answer in one short sentence.
      Name bell buoy 2 and keep the 270-degree bearing the chart clerk already posted.
      Do not invent a voltage.
    TEXT
  end

  class ChartNotice
    CORRECTION_QUESTION = <<~TEXT.strip
      Chart correction for the Strait of Juan de Fuca, Wednesday 15 October 2026.
      Chart catalog: https://www.nauticalcharts.noaa.gov/.
      Bell buoy 2 off Ediz Hook is relocated. New bearing 270 degrees true from the hook.
      Least depth 8 fathoms, sand and shell.
      What should the chart clerk post?
    TEXT

    TICKET_QUESTION = "Post the Ediz Hook ticket from that correction. Does the watch keep the 270-degree bearing?"

    Result = Struct.new(
      :correction,
      :ticket,
      :same_object,
      :roles,
      :second_instructions,
      keyword_init: true
    )

    def self.conduct
      configure
      chart = open_agent(ChartClerk)
      correction = chart.ask(CORRECTION_QUESTION)
      buoy = BuoyClerk.new(chat: chart.chat)
      ticket = buoy.ask(TICKET_QUESTION)

      Result.new(
        correction: correction.content,
        ticket: ticket.content,
        same_object: buoy.chat.equal?(chart.chat),
        roles: buoy.messages.map(&:role),
        second_instructions: buoy.messages.select { |message| message.role == :system }.map(&:content)
      )
    end

    def self.open_agent(klass)
      chosen = Multivitamin::Models.chat(provider: :openai)
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      agent = klass.new(model: chosen[:model], **kwargs)
      Multivitamin::Models.quiet_thinking(agent, provider: :openai)
      agent
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "chart_handoff") do
    result = JuanDeFucaChartHandoff::ChartNotice.conduct
  end

  puts result.correction
  puts
  puts result.ticket
end
