# frozen_string_literal: true

# Agents · 02 · New Dungeness lens cabinet
#
# Teaches:
# - The tools macro registers a RubyLLM::Tool on every chat the agent builds.
# - tool_options choice: forces that tool on the first ask.
# - self.tool_name keeps a short domain name.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NewDungenessLensCabinet
  class PostedLensDrawer < RubyLLM::Tool
    description "Reads the bullseye drawer card posted in the New Dungeness lens cabinet"

    def self.tool_name
      "posted_lens_drawer"
    end

    CARD = <<~TEXT.strip
      New Dungeness lens cabinet, Wednesday 15 October 2026.
      Station notes: https://newdungenesslighthouse.com/
      Bullseye drawer: spare 4th-order panel, wrapped, marked ND-4.
    TEXT

    def execute
      CARD
    end
  end

  class LensKeeper < RubyLLM::Agent
    model Multivitamin::Models::OPENAI_CHAT, provider: :openai
    tools PostedLensDrawer
    tool_options choice: PostedLensDrawer
    temperature 0.2

    instructions <<~TEXT.strip
      You are the lens keeper at New Dungeness Light Station.
      Call posted_lens_drawer once.
      Answer in one short sentence and include the mark ND-4.
      Do not invent a drawer.
    TEXT
  end

  class CabinetBrief
    DRAWER_QUESTION = <<~TEXT.strip
      Gallery watch at New Dungeness, Wednesday 15 October 2026.
      Station notes: https://newdungenesslighthouse.com/
      The relief wants the bullseye drawer opened before the lamp is trimmed.
      What is in that drawer?
    TEXT

    Result = Struct.new(
      :answer,
      :roles,
      :tool_content,
      :tool_names,
      :finish,
      :cost,
      keyword_init: true
    )

    def self.conduct
      configure
      agent = open_agent
      answer = agent.ask(DRAWER_QUESTION)
      tool_message = agent.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: agent.messages.map(&:role),
        tool_content: tool_message&.content,
        tool_names: agent.tools.keys.map(&:to_s),
        finish: answer.finish_reason,
        cost: answer.cost.total
      )
    end

    def self.open_agent
      chosen = Multivitamin::Models.chat(provider: :openai)
      kwargs = { provider: chosen[:provider] }
      kwargs[:assume_model_exists] = true if chosen[:assume_model_exists]
      agent = LensKeeper.new(model: chosen[:model], **kwargs)
      Multivitamin::Models.quiet_thinking(agent, provider: :openai)
      agent
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
  Multivitamin::Cassettes.play(__dir__, "lens_cabinet") do
    result = NewDungenessLensCabinet::CabinetBrief.conduct
  end

  puts result.answer
end
