# frozen_string_literal: true

# Models and providers · 01 · Valencia Fallas commission board
#
# Teaches:
# - RubyLLM.models.chat_models lists registry entries of type :chat.
# - context_window is an Integer or nil, read off those entries.
# - Listing the bundled registry does not open a socket.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"

module ValenciaFallas
  # The Junta Central Fallera posts which chat models can hold the day's
  # ninot commission list, the way the falla posts which workshops can
  # take a street's figures.
  class CommissionBoard
    Result = Struct.new(
      :chat_count,
      :openai_chat_count,
      :openai_windows,
      :openai_nil_windows,
      :long_board_id,
      :long_board_provider,
      :long_board_window,
      :types,
      keyword_init: true
    )

    def self.conduct
      configure

      chat_models = RubyLLM.models.chat_models
      openai_chats = chat_models.by_provider(:openai)
      windows = openai_chats.filter_map(&:context_window)
      long_board = RubyLLM.models.find("gpt-4.1-mini", provider: :openai)

      Result.new(
        chat_count: chat_models.count,
        openai_chat_count: openai_chats.count,
        openai_windows: windows,
        openai_nil_windows: openai_chats.count { |model| model.context_window.nil? },
        long_board_id: long_board.id,
        long_board_provider: long_board.provider,
        long_board_window: long_board.context_window,
        types: chat_models.map(&:type).uniq
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.max_retries = 0
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "commission_board") do
    result = ValenciaFallas::CommissionBoard.conduct
  end

  puts "#{result.chat_count} chat models on the Fallas board"
  puts "#{result.long_board_id} window #{result.long_board_window}"
end
