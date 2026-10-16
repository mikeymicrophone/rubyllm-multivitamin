# frozen_string_literal: true

# Models and providers · 13 · Maseru oxygen-run capstone
#
# Teaches:
# - Filter chat models by supports?(:function_calling), then assume a
#   free slug and ask one station question.
# - The capability filter is the board; assume_model_exists is how a
#   newer slug still gets on the radio.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MaseruOxygen
  # The highland clinic in Maseru filters clerks who can call tools, puts
  # the free OpenRouter slug on the radio with assume, and asks whether
  # cylinder Oxy-4 can leave on the morning run.
  class OxygenQuestion
    INSTRUCTIONS = <<~TEXT.strip
      You are the cylinder clerk at a highland clinic in Maseru.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Use only the fill card in the question.
      Name Oxy-4.
      Do not invent pressures.
    TEXT

    FILL_QUESTION = <<~TEXT.strip
      Maseru highland clinic fill card, Wednesday 14 October 2026.
      Clinic page: https://www.health.gov.ls/
      Fill desk: cylinder Oxy-4, posted leave pressure 4.0 bar.
      Morning reading 07:22, 0.8 bar.
      Mid-fill reading 11:40, 5.2 bar.
      Afternoon fill complete 13:10, 8.4 bar.
      The compressor is still rising toward 8.4 bar.
      Oxy-4 needs 4.0 bar to leave on the highland run to Thaba-Tseka.
      Can Oxy-4 leave at 11:40, and is 4.0 bar already behind the 5.2 bar mid-fill on the way to 8.4?
    TEXT

    Result = Struct.new(
      :tool_clerk_count,
      :slug_has_tools,
      :chat_model_id,
      :chat_provider,
      :assumed_warning,
      :brief,
      :roles,
      :finish,
      :input_tokens,
      :output_tokens,
      keyword_init: true
    )

    def self.conduct
      configure

      tool_clerks = RubyLLM.models.chat_models.select { |model|
        model.supports?(:function_calling)
      }
      slug = Multivitamin::Models::CHAT
      slug_entry = tool_clerks.find { |model|
        model.id == slug && model.provider == "openrouter"
      }

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      brief = chat.ask(FILL_QUESTION)

      Result.new(
        tool_clerk_count: tool_clerks.count,
        slug_has_tools: !slug_entry.nil?,
        chat_model_id: chat.model.id,
        chat_provider: chat.model.provider,
        assumed_warning: chat.model.metadata[:warning],
        brief: brief.content,
        roles: chat.messages.map(&:role),
        finish: brief.finish_reason,
        input_tokens: brief.tokens.input,
        output_tokens: brief.tokens.output
      )
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
  Multivitamin::Cassettes.play(__dir__, "oxygen_question") do
    result = MaseruOxygen::OxygenQuestion.conduct
  end

  puts "#{result.tool_clerk_count} tool clerks, slug tools=#{result.slug_has_tools}"
  puts "#{result.chat_provider} #{result.chat_model_id}"
  puts
  puts result.brief
end
