# frozen_string_literal: true

# Tokens and cost · 05 · Point No Point current-gate cap
#
# Teaches:
# - with_max_output_tokens is a token budget on the reply.
# - A tight cap can finish with max_tokens? true.
# - tokens.output still reports the tokens that were used under that cap.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module PointNoPointCurrentGate
  # The current clerk at Point No Point tries to post a Hansville gate
  # note under a 64-token budget. The watch reads finish_reason and the
  # output count, not only the spoken words.
  class CurrentGate
    INSTRUCTIONS = <<~TEXT.strip
      You are the current clerk at Point No Point Light, north of Hansville.
      Use only the current table in this chat.
      Name flood 3.1 knots and the skiff Hansville.
      Do not invent a slack time.
    TEXT

    TABLE_QUESTION = <<~TEXT.strip
      Admiralty Inlet current table copied at Point No Point, Wednesday 14 October 2026.
      Station page: https://tidesandcurrents.noaa.gov/stationhome.html?id=9444900
      Light list: https://www.navcen.uscg.gov/
      Flood 3.1 knots at 11:20, setting 160 true past the Hansville pier.
      Slack before ebb 14:05.
      The kelp skiff Hansville needs slack to work the eelgrass bar off Norwegian Point.
      Write two sentences the watch can post: the flood figure, the slack clock, and that Hansville waits for 14:05.
    TEXT

    OUTPUT_BUDGET = 64

    Result = Struct.new(
      :content,
      :thinking,
      :finish,
      :max_tokens,
      :output_tokens,
      :thinking_tokens,
      :input_tokens,
      :output_cap,
      :raw_status,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_max_output_tokens(OUTPUT_BUDGET)
      note = chat.ask(TABLE_QUESTION)

      Result.new(
        content: note.content,
        thinking: note.thinking&.text,
        finish: note.finish_reason,
        max_tokens: note.max_tokens?,
        output_tokens: note.tokens.output,
        thinking_tokens: note.tokens.thinking,
        input_tokens: note.tokens.input,
        output_cap: chat.max_output_tokens,
        raw_status: note.raw.status
      )
    end

    def self.open_chat
      RubyLLM.chat(**Multivitamin::Models.chat(provider: :openrouter))
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
  Multivitamin::Cassettes.play(__dir__, "current_gate") do
    result = PointNoPointCurrentGate::CurrentGate.conduct
  end

  puts "finish=#{result.finish} max_tokens=#{result.max_tokens} out=#{result.output_tokens} " \
       "thinking=#{result.thinking_tokens} cap=#{result.output_cap}"
  puts result.content.inspect
end
