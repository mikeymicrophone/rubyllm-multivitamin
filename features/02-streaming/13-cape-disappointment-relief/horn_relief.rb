# frozen_string_literal: true

# Streaming · 13 · Cape Disappointment horn relief
#
# Teaches:
# - A streamed tool call arrives as partial argument strings on the chunks.
# - before_tool_call receives the finished call. The chunk is not where the
#   tool runs.
# - After the tool, the spoken relief can be cancelled on a later chunk.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module CapeDisappointmentRelief
  # The posted horn card is not in the question. The relief has to read it
  # through the tool, then the outgoing watch starts to speak and is stopped.
  class PostedHornCard < RubyLLM::Tool
    description "Reads the foghorn card posted at Cape Disappointment"

    def execute(station:)
      "Cape Disappointment horn card for #{station}. Blast 2.5 seconds, silent 17.5 seconds. Compressor 92 psi."
    end
  end

  class HornRelief
    INSTRUCTIONS = <<~TEXT.strip
      You are the outgoing foghorn watch at Cape Disappointment Light.
      Call the posted horn card tool for the station in the question.
      Then speak one short sentence for the relief that includes the blast and the compressor.
    TEXT

    RELIEF_QUESTION = <<~TEXT.strip
      The relief is taking the horn watch at Cape Disappointment on Wednesday 14 October 2026.
      Station notes: https://www.nps.gov/places/cape-disappointment-lighthouse.htm
      Read the posted horn card for Cape Disappointment and start the spoken relief.
    TEXT

    Result = Struct.new(
      :spoken,
      :error,
      :roles,
      :tool_content,
      :tool_arguments,
      :argument_fragments,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_thinking(false)
      chat.with_tools(PostedHornCard)
      chat.with_tool_options(choice: PostedHornCard)

      tool_arguments = nil
      chat.before_tool_call { |tool_call| tool_arguments = tool_call.arguments }

      spoken = []
      fragments = []
      error = nil
      begin
        chat.ask(RELIEF_QUESTION) do |chunk|
          if chunk.tool_call?
            chunk.tool_calls.each_value do |call|
              fragments << [call.name, call.arguments]
            end
          end

          piece = chunk.content.to_s
          next if piece.empty?

          spoken << piece
          chat.cancel if tool_arguments && spoken.size == 2
        end
      rescue RubyLLM::CancelledError => raised
        error = raised
      end

      tool_message = chat.messages.find { |message| message.role == :tool }

      Result.new(
        spoken: spoken,
        error: error,
        roles: chat.messages.map(&:role),
        tool_content: tool_message&.content,
        tool_arguments: tool_arguments,
        argument_fragments: fragments
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
  Multivitamin::Cassettes.play(__dir__, "horn_relief") do
    result = CapeDisappointmentRelief::HornRelief.conduct
  end

  puts result.spoken.join
  puts
  puts result.tool_content
  puts result.error.class
end
