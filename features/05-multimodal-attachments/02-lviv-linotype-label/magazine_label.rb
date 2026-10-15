# frozen_string_literal: true

# Multimodal attachments · 02 · Lviv linotype label
#
# Teaches:
# - Build a RubyLLM::Attachment when the call needs resolution:.
# - :high asks the provider for the finer image detail.
# - The attachment object is what with: receives. A path is not required.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module LvivMagazineLabel
  # The magazine label is small. The compositor asks for high detail so the
  # point size survives.
  class MagazineLabel
    LABEL = File.expand_path("magazine-label.png", __dir__)

    INSTRUCTIONS = <<~TEXT.strip
      You are the compositor at a Lviv linotype shop.
      Answer in one sentence from the label only.
      Include the magazine number and the point size.
      Do not invent a figure.
    TEXT

    LABEL_QUESTION = "What magazine is this, and what point size is printed for the Garamond matrices?"

    Result = Struct.new(:reading, :resolution, :finish, :input_tokens, :cost, keyword_init: true)

    def self.conduct
      configure
      label = RubyLLM::Attachment.new(LABEL, resolution: :high)
      chat = open_chat
      chat.with_instructions(INSTRUCTIONS)
      reading = chat.ask(LABEL_QUESTION, with: label)

      Result.new(
        reading: reading.content,
        resolution: label.resolution,
        finish: reading.finish_reason,
        input_tokens: reading.tokens.input,
        cost: reading.cost.total
      )
    end

    def self.open_chat
      chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
      chat.with_temperature(0)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
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
  Multivitamin::Cassettes.play(__dir__, "magazine_label") do
    result = LvivMagazineLabel::MagazineLabel.conduct
  end

  puts result.reading
end
