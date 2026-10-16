# frozen_string_literal: true

# Configuration and contexts · 03 · Sousse olive press and medina stall
#
# Teaches:
# - RubyLLM.context dups the global Configuration and yields the copy.
# - ctx.chat uses the copy. Two tenants can set different app names.
# - RubyLLM.config is left as it was after both chats.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module SoussePressAndStall
  # Huilerie Riadh and the Souk el-Caïd stall each get an isolated
  # context. The global attribution stays the catalog's.
  class Tenants
    GLOBAL_TITLE = "RubyLLM Multivitamin"
    MILL_TITLE = "Huilerie Riadh press desk"
    STALL_TITLE = "Souk el-Caïd stall"
    MILL_URL = "https://www.commune-sousse.gov.tn/"
    STALL_URL = "https://www.commune-sousse.gov.tn/medina"

    MILL_INSTRUCTIONS = <<~TEXT.strip
      You are the press clerk at Huilerie Riadh in Sousse.
      Answer in one short sentence.
      Use only the press card in the question.
      Name Youssef and 06:40.
      Do not invent an acidity.
    TEXT

    MILL_QUESTION = <<~TEXT.strip
      Morning press card for Wednesday 14 October 2026 at Huilerie Riadh, Sousse.
      Commune page: https://www.commune-sousse.gov.tn/.
      First cold press starts at 06:40.
      Youssef runs the stone wheel.
      Posted acidity 0.4 percent.
      When does Youssef start the first press?
    TEXT

    STALL_INSTRUCTIONS = <<~TEXT.strip
      You are the stall clerk at Souk el-Caïd in the Sousse medina.
      Answer in one short sentence.
      Use only the receiving card in the question.
      Name harissa and 12.
      Do not invent a tin count.
    TEXT

    STALL_QUESTION = <<~TEXT.strip
      Receiving card for Wednesday 14 October 2026, Souk el-Caïd stall.
      Medina page: https://www.commune-sousse.gov.tn/medina.
      Lot SOS-314: 12 tins of harissa.
      Lot SOS-208: 4 sacks of couscous, already stacked.
      Write the log line for the stall book.
    TEXT

    Result = Struct.new(
      :mill_brief,
      :stall_log,
      :mill_title,
      :stall_title,
      :global_title_after,
      :global_url_after,
      keyword_init: true
    )

    def self.conduct
      configure
      args = ConfigurationPaidOpenrouter.chat_args

      mill = RubyLLM.context do |config|
        config.openrouter_app_name = MILL_TITLE
        config.openrouter_app_url = MILL_URL
      end
      mill_chat = open_chat(mill, args)
      mill_chat.with_instructions(MILL_INSTRUCTIONS)
      mill_chat.with_temperature(0.2)
      mill_brief = mill_chat.ask(MILL_QUESTION)

      stall = RubyLLM.context do |config|
        config.openrouter_app_name = STALL_TITLE
        config.openrouter_app_url = STALL_URL
      end
      stall_chat = open_chat(stall, args)
      stall_chat.with_instructions(STALL_INSTRUCTIONS)
      stall_chat.with_temperature(0.2)
      stall_log = stall_chat.ask(STALL_QUESTION)

      Result.new(
        mill_brief: mill_brief.content,
        stall_log: stall_log.content,
        mill_title: mill.config.openrouter_app_name,
        stall_title: stall.config.openrouter_app_name,
        global_title_after: RubyLLM.config.openrouter_app_name,
        global_url_after: RubyLLM.config.openrouter_app_url
      )
    end

    def self.open_chat(context, args)
      ConfigurationPaidOpenrouter.prepare(context.chat(**args))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
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
  Multivitamin::Cassettes.play(__dir__, "tenants") do
    result = SoussePressAndStall::Tenants.conduct
  end

  puts "mill (#{result.mill_title}):"
  puts result.mill_brief
  puts
  puts "stall (#{result.stall_title}):"
  puts result.stall_log
end
