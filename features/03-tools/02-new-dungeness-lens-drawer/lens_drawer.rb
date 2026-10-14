# frozen_string_literal: true

# Tools · 02 · New Dungeness lens drawer
#
# Teaches:
# - A required keyword on execute becomes a required string parameter
#   when the tool does not declare parameter.
# - call returns { error: } for a missing or unknown keyword. execute
#   does not run, and nothing is raised.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NewDungenessLensDrawer
  # The keeper names a drawer. The tool's schema is inferred from execute.
  class LensDrawer < RubyLLM::Tool
    description "Looks up one drawer in the Fresnel lens cabinet at New Dungeness"

    def self.tool_name
      "lens_drawer"
    end

    DRAWERS = {
      "bullseye" => "Bullseye drawer: spare 4th-order panel, wrapped, marked ND-4.",
      "clockwork" => "Clockwork drawer: rotation weights for a 30-second flash.",
      "chimney" => "Chimney drawer: two lamp chimneys, one cracked."
    }.freeze

    def execute(drawer:)
      DRAWERS.fetch(drawer.to_s.downcase) { "No drawer named #{drawer} in the New Dungeness cabinet." }
    end
  end

  class DrawerLookup
    INSTRUCTIONS = <<~TEXT.strip
      You are the lens keeper at New Dungeness Light Station.
      Call lens_drawer with the drawer the watch named.
      Answer in one sentence and include the mark the tool returns.
    TEXT

    DRAWER_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, gallery watch at New Dungeness.
      Station notes: https://newdungenesslighthouse.com/
      The relief wants the bullseye drawer opened before the lamp is trimmed.
      What is in that drawer?
    TEXT

    Result = Struct.new(:answer, :roles, :tool_content, :arguments, keyword_init: true)

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)
      chat.with_tools(LensDrawer)
      chat.with_tool_options(choice: LensDrawer)

      answer = chat.ask(DRAWER_QUESTION)
      tool_call = chat.messages.find(&:tool_call?)&.tool_calls&.values&.first
      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        answer: answer.content,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        arguments: tool_call&.arguments
      )
    end

    def self.open_chat
      RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        # Chat Completions emits a developer role unless this is set.
        # OpenRouter expects system. The flag is shared with OpenAI's formatter.
        config.openai_use_system_role = true
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
  Multivitamin::Cassettes.play(__dir__, "lens_drawer") do
    result = NewDungenessLensDrawer::DrawerLookup.conduct
  end

  puts result.answer
end
