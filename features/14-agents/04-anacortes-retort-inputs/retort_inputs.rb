# frozen_string_literal: true

# Agents · 04 · Anacortes retort inputs
#
# Teaches:
# - inputs :retort makes that keyword a method inside lazy blocks.
# - instructions { } reads the retort name when the agent is built.
# - The model block can read inputs too; it cannot read chat.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AnacortesRetortInputs
  Retort = Struct.new(:name, :basket, :temperature_f, keyword_init: true)

  class CookClerk < RubyLLM::Agent
    inputs :retort
    model do
      if retort.basket == "Basket 3"
        Multivitamin::Models.chat(provider: :openai).fetch(:model)
      else
        Multivitamin::Models::CHAT_FALLBACK
      end
    end
    temperature 0.2

    instructions do
      <<~TEXT.strip
        You are the retort clerk on #{retort.name} at the Anacortes cannery.
        Answer in one short sentence from the cook card only.
        Name #{retort.name}, #{retort.basket}, and #{retort.temperature_f} F.
        Do not invent a lot code.
      TEXT
    end
  end

  class MorningCook
    COOK_QUESTION = <<~TEXT.strip
      Morning cook card for Wednesday 15 October 2026.
      Marina: https://www.portofanacortes.com/.
      Posted temperature 242 F.
      Basket 3 of sockeye on Retort No. 2.
      Write the log line for the cannery office.
    TEXT

    Result = Struct.new(
      :log_line,
      :roles,
      :declared_inputs,
      :instructions,
      :retort_name,
      keyword_init: true
    )

    def self.conduct
      configure
      kettle = Retort.new(name: "Retort No. 2", basket: "Basket 3", temperature_f: 242)
      agent = open_agent(kettle)
      log_line = agent.ask(COOK_QUESTION)

      Result.new(
        log_line: log_line.content,
        roles: agent.messages.map(&:role),
        declared_inputs: CookClerk.inputs,
        instructions: agent.messages.find { |message| message.role == :system }&.content,
        retort_name: kettle.name
      )
    end

    def self.open_agent(kettle)
      chosen = Multivitamin::Models.chat(provider: :openai)
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      agent = CookClerk.new(retort: kettle, **kwargs)
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
  Multivitamin::Cassettes.play(__dir__, "retort_inputs") do
    result = AnacortesRetortInputs::MorningCook.conduct
  end

  puts result.log_line
end
