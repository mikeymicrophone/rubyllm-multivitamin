# frozen_string_literal: true

# Image generation · 13 · Admiralty Inlet chart handover
#
# Teaches:
# - paint, then save, then chat.ask with: the saved path.
# - The generated plate is the user attachment on the next turn.
# - A 1x1 PNG stand-in replaces the saved bytes before ask so the
#   cassette stays small. Replay and live send the same attachment.

require "logger"
require "ruby_llm"
require "tmpdir"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AdmiraltyInletChartHandover
  # The outgoing watch at Admiralty Inlet paints the chart table, files
  # the plate, and asks the relief clerk whether the plate is in hand.
  class ChartHandover
    PAINT_PROMPT = <<~TEXT.strip
      Chart table at the Admiralty Inlet watch desk with parallel rulers,
      NOAA chart 18441, and the Point Wilson tide board in the margin.
      Lamp over the table. Documentary. No people.
    TEXT

    INSTRUCTIONS = <<~TEXT.strip
      You are the relief clerk at the Admiralty Inlet watch desk.
      You have been handed a painted plate of the chart table.
      Answer in one short sentence.
      Name Admiralty Inlet.
      Say whether you have the plate.
      Do not invent a tide height.
    TEXT

    QUESTION = "Confirm you have the painted chart-table plate and name the inlet."

    Result = Struct.new(:paint_model, :saved_path, :answer, :roles, keyword_init: true)

    def self.conduct
      configure

      image = RubyLLM.paint(PAINT_PROMPT, **Multivitamin::Models.image_paint)
      path = File.join(Dir.mktmpdir("admiralty-chart-"), "chart_table.png")
      image.save(path)
      # Live bytes are megabytes of PNG. The stand-in keeps the chat request
      # small and identical on replay, after the cassette has shrunk b64_json.
      File.binwrite(path, Multivitamin::Cassettes::TINY_PNG)

      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      answer = chat.ask(QUESTION, with: path)

      Result.new(
        paint_model: image.model,
        saved_path: path,
        answer: answer.content,
        roles: chat.messages.map(&:role)
      )
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
  Multivitamin::Cassettes.play(__dir__, "chart_handover") do
    result = AdmiraltyInletChartHandover::ChartHandover.conduct
  end

  puts result.answer
end
