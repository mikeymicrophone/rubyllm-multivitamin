# frozen_string_literal: true

# MCP client · 13 · Admiralty Inlet capstone
#
# Teaches:
# - A class, with_mcp, a resource attachment, and a follow-up ask share one desk.
# - The second question uses the earlier tool result without repeating the board.
# - close ends the stdio process.

require "logger"
require "rbconfig"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AdmiraltyInletMcpCapstone
  SERVER = File.expand_path("../stdio_server.rb", __dir__)
  PROFILE = File.expand_path("desk.json", __dir__)

  class AdmiraltyInletWatchDesk < RubyLLM::MCP
    command RbConfig.ruby, SERVER, PROFILE
    only :posted_tide_board, :posted_horn_card
    prefix :admiralty
  end

  class WatchCapstone
    INSTRUCTIONS = <<~TEXT.strip
      You are the watch clerk at Point Wilson on Admiralty Inlet.
      Call admiralty_posted_tide_board for the first question.
      Call admiralty_posted_horn_card for the second.
      Each answer is one sentence that includes the figure the desk returned.
      Name Alden. The attached latch card is the lens cabinet.
    TEXT

    TIDE_QUESTION = <<~TEXT.strip
      Wednesday 14 October 2026, morning watch at Point Wilson.
      Tide reference: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      When does the foghorn tender Alden clear the kelp ledge?
    TEXT

    HORN_QUESTION = "The relief asks whether the horn is running, and what the blast is. The latch card is attached."

    Result = Struct.new(
      :tide_answer,
      :horn_answer,
      :roles,
      :tool_contents,
      :latch_uri,
      :tool_names,
      keyword_init: true
    )

    def self.conduct
      configure
      desk = AdmiraltyInletWatchDesk.new
      latch = desk.resource("watch://admiralty-inlet/lens-latch.md")
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat.with_mcp(desk)
      tide = chat.ask(TIDE_QUESTION)
      horn = chat.ask(HORN_QUESTION, with: latch)

      Result.new(
        tide_answer: tide.content,
        horn_answer: horn.content,
        roles: chat.messages.map(&:role),
        tool_contents: chat.messages.select { |message| message.role == :tool }.map(&:content),
        latch_uri: latch.uri,
        tool_names: chat.tools.keys.map(&:to_s)
      )
    ensure
      desk&.close
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
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
  Multivitamin::Cassettes.play(__dir__, "watch_capstone") do
    result = AdmiraltyInletMcpCapstone::WatchCapstone.conduct
  end

  puts result.tide_answer
  puts result.horn_answer
end
