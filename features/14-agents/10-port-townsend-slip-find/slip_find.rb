# frozen_string_literal: true

# Agents · 10 · Port Townsend slip find
#
# Teaches:
# - create! persists the slip chat and the first brief.
# - find loads that row and applies the agent at runtime.
# - find does not write a second system row. The follow-up still sees the gust.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/active_record"

module PortTownsendSlipFind
  class SlipChat < ActiveRecord::Base
    self.table_name = "port_townsend_agent_slips"
    acts_as_chat messages: :slip_turns,
                 message_class: "PortTownsendSlipFind::SlipTurn",
                 messages_foreign_key: :port_townsend_agent_slip_id
  end

  class SlipTurn < ActiveRecord::Base
    self.table_name = "port_townsend_agent_turns"
    acts_as_message chat: :slip_chat,
                    chat_class: "PortTownsendSlipFind::SlipChat",
                    chat_foreign_key: :port_townsend_agent_slip_id
  end

  class SlipClerk < RubyLLM::Agent
    chat_model SlipChat
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    temperature 0.2

    instructions <<~TEXT.strip
      You are the slip clerk at the Port Townsend ferry slip.
      Answer in one short sentence from the wind board only.
      Name the 28-knot gust and the Kalakala holding.
    TEXT
  end

  class WindBoard
    WIND_QUESTION = <<~TEXT.strip
      Wind board at the Port Townsend ferry slip, Wednesday 15 October 2026.
      Terminal page: https://wsdot.wa.gov/travel/washington-state-ferries
      Southwesterly 18 knots, gusting 28. The Kalakala holds for the gust.
      What does the incoming watch post?
    TEXT

    HOLD_QUESTION = "The Kalakala asks again: does she hold for that 28-knot gust?"

    Result = Struct.new(
      :opening,
      :follow_up,
      :same_id,
      :system_count,
      :roles,
      :found_class,
      keyword_init: true
    )

    def self.conduct
      chosen = boot
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      slip = SlipClerk.create!(model: chosen[:model], **kwargs)
      Multivitamin::Models.quiet_thinking(slip, provider: :openai)
      opening = slip.ask(WIND_QUESTION)
      found = SlipClerk.find(slip.id)
      follow_up = found.ask(HOLD_QUESTION)

      Result.new(
        opening: opening.content,
        follow_up: follow_up.content,
        same_id: found.id == slip.id,
        system_count: found.slip_turns.where(role: :system).count,
        roles: found.slip_turns.map { |turn| turn.role.to_sym },
        found_class: found.class.name
      )
    end

    def self.boot
      Multivitamin::ActiveRecordBoot.prepare!(
        chat_table: :port_townsend_agent_slips,
        message_table: :port_townsend_agent_turns,
        message_foreign_key: :port_townsend_agent_slip_id
      )
      chosen = Multivitamin::Models.chat(provider: :openai)
      Multivitamin::ActiveRecordBoot.seed_model(model_id: chosen[:model], provider: chosen[:provider])
      configure
      chosen
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
  Multivitamin::Cassettes.play(__dir__, "slip_find") do
    result = PortTownsendSlipFind::WindBoard.conduct
  end

  puts result.opening
  puts
  puts result.follow_up
end
