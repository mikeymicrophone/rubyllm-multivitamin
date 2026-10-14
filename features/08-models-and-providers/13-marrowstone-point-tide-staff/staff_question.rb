# frozen_string_literal: true

# Models and providers · 13 · Marrowstone Point tide-staff capstone
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

module MarrowstonePointStaff
  # The keeper at Marrowstone Point Light filters clerks who can call
  # tools, puts the free OpenRouter slug on the radio with assume, and
  # asks when the skiff Nettie can clear the eelgrass bar.
  class StaffQuestion
    INSTRUCTIONS = <<~TEXT.strip
      You are the keeper at Marrowstone Point Light, east of Port Townsend.
      Answer in two short sentences.
      The first sentence starts with Yes or No.
      Use only the tide staff in the question.
      Name Nettie.
      Do not invent tide heights.
    TEXT

    STAFF_QUESTION = <<~TEXT.strip
      Marrowstone Point tide staff, Wednesday 14 October 2026.
      Light list: https://www.navcen.uscg.gov/
      Tide reference: https://tidesandcurrents.noaa.gov/ station 9444900.
      Low water 07:22, 0.8 ft above MLLW.
      High water 13:10, 8.4 ft.
      The kelp skiff Nettie needs 4.0 ft at the staff to clear the eelgrass bar off Mystery Bay.
      Can Nettie leave on the rise after 07:22, and is 4.0 ft on the way to the 8.4 ft high?
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
      brief = chat.ask(STAFF_QUESTION)

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
  Multivitamin::Cassettes.play(__dir__, "staff_question") do
    result = MarrowstonePointStaff::StaffQuestion.conduct
  end

  puts "#{result.tool_clerk_count} tool clerks, slug tools=#{result.slug_has_tools}"
  puts "#{result.chat_provider} #{result.chat_model_id}"
  puts
  puts result.brief
end
