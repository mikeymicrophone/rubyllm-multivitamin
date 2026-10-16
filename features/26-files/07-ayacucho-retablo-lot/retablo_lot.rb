# frozen_string_literal: true

# Files · 07 · Ayacucho retablo lot
#
# Teaches:
# - One upload serves two asks. The second with: is the same UploadedFile.
# - Anthropic reuse needs a key this catalog does not have.
# - The cassette is Files once, then two Responses.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AyacuchoRetabloLot
  class RetabloLot
    LOT = File.expand_path("retablo-lot.pdf", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the retablo clerk in Ayacucho.
      Answer in one short sentence from the lot card only.
      Name Rosa and AYC-2026-1016-R5.
    TEXT

    BOX_QUESTION = "How many boxes are on the lot card? Reply with the number only."
    TIME_QUESTION = "When does Rosa pack? Reply with the clock only."

    Result = Struct.new(:file_id, :boxes, :clock, :roles, keyword_init: true)

    def self.conduct
      configure

      file = RubyLLM.upload(LOT, provider: :openai, purpose: "user_data")
      chat = RubyLLM.chat(**Multivitamin::Models.chat(provider: :openai))
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      boxes = chat.ask(BOX_QUESTION, with: file)
      clock = chat.ask(TIME_QUESTION, with: file)

      Result.new(
        file_id: file.id,
        boxes: boxes.content,
        clock: clock.content,
        roles: chat.messages.map(&:role)
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
  Multivitamin::Cassettes.play(__dir__, "retablo_lot") do
    result = AyacuchoRetabloLot::RetabloLot.conduct
  end

  puts result.file_id
  puts result.boxes
  puts result.clock
end
