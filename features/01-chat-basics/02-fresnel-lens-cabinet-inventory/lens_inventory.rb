# frozen_string_literal: true

# Chat basics · 02 · Fresnel lens cabinet inventory
#
# Teaches:
# - One RubyLLM.chat, one ask, one RubyLLM::Message back.
# - content, role, and model (the id string) are read off that message.
# - tokens.input and tokens.output are the counts for this turn.
# - finish_reason says why the model stopped.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module NewDungenessLensCabinet
  # The relief keeper at New Dungeness counts one cabinet. The question
  # is a single ask, and the whole lesson is what the message gives back.
  class LensInventory
    INSTRUCTIONS = <<~TEXT.strip
      You are the lens keeper at New Dungeness Light Station on the Dungeness Spit.
      Answer in two short sentences.
      Use only the cabinet list in the question.
      Quote catalog marks exactly as printed.
      Do not invent drawers, prisms, or chimneys.
    TEXT

    CABINET_QUESTION = <<~TEXT.strip
      Cabinet list posted in the lens room at New Dungeness Light.
      The station log is kept for https://newdungenesslighthouse.com/ and the
      sector this fourth-order lens marks is drawn on https://www.nauticalcharts.noaa.gov/.
      Drawer A: fourth-order center prism, cracked, catalog NP-4, do not issue.
      Drawer B: spare bull's-eye, catalog NB-17.
      Drawer C: six lamp chimneys, catalog LC-6.
      Drawer D: clockwork weight chain, catalog CW-2, seized and waiting on a pin.
      Which drawer holds the spare bull's-eye, and how many chimneys are in drawer C?
      Quote both catalog marks.
    TEXT

    Result = Struct.new(
      :content,
      :role,
      :model_id,
      :chat_model_id,
      :finish_reason,
      :input_tokens,
      :output_tokens,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)

      reply = chat.ask(CABINET_QUESTION)

      Result.new(
        content: reply.content,
        role: reply.role,
        model_id: reply.model,
        chat_model_id: chat.model.id,
        finish_reason: reply.finish_reason,
        input_tokens: reply.tokens.input,
        output_tokens: reply.tokens.output,
        roles: chat.messages.map(&:role)
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
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "lens_inventory") do
    result = NewDungenessLensCabinet::LensInventory.conduct
  end

  puts result.content
  puts
  puts "role=#{result.role} model=#{result.model_id} finish=#{result.finish_reason} " \
       "tokens=#{result.input_tokens}/#{result.output_tokens}"
end
