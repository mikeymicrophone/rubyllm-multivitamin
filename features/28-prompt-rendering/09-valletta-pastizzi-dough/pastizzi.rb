# frozen_string_literal: true

# Prompt rendering · 09 · Valletta pastizzi dough
#
# Teaches:
# - Do not interpolate an untrusted stall name into a prompt path.
# - Map a known card onto a constant prompt name.
# - An unknown card is ArgumentError before render_prompt runs.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../../../support/prompts"

module VallettaPastizziDough
  class PastizziDesk
    CARDS = {
      "pastizzi" => "pastizzi/instructions"
    }.freeze

    BOARD = "Board: Lucia folds lot VLT-2026-1016-P6 at 07:10. When does Lucia fold?"

    Result = Struct.new(:rendered, :brief, :unknown, keyword_init: true)

    def self.conduct
      configure
      Multivitamin::Prompts.in_root(__dir__) do
        rendered = render_stall("pastizzi")
        unknown = nil
        begin
          render_stall("../etc/passwd")
        rescue ArgumentError => raised
          unknown = raised
        end
        chat = open_chat
        chat.with_instructions(rendered)
        chat.with_temperature(0.2)
        brief = chat.ask(BOARD)
        Result.new(rendered: rendered, brief: brief.content, unknown: unknown)
      end
    end

    def self.render_stall(choice)
      name = CARDS.fetch(choice) { raise ArgumentError, "unknown stall card #{choice}" }
      RubyLLM.render_prompt(name, baker: "Lucia", lot: "VLT-2026-1016-P6")
    end

    def self.open_chat
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "pastizzi") do
    result = VallettaPastizziDough::PastizziDesk.conduct
  end

  puts result.brief
  puts result.unknown.message
end
