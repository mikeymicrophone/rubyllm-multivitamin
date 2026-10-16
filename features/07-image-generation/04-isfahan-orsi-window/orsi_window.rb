# frozen_string_literal: true

# Image generation · 04 · Isfahan orsi window
#
# Teaches:
# - Image#url is nil when the provider returns inline bytes.
# - Image#base64? is true and Image#data holds the Base64 payload.
# - gpt-image-1-mini has no response_format: url. Asking for it is a
#   BadRequestError, shown in slot 12's cousin: this slot reads the
#   delivery that actually arrived.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module IsfahanOrsiWindow
  # The restoration atelier in Jolfa needs a plate of the orsi window
  # delivered as bytes, not a hosted URL: the workshop PCs have no
  # outbound HTTP.
  class OrsiWindow
    PROMPT = <<~TEXT.strip
      Orsi stained-glass window of a Safavid house in Jolfa, Isfahan, at dusk.
      The wooden lattice and the cobalt-and-amber panes sit over the courtyard.
      Wet plaster, oil lamp, documentary. No figures invented in the courtyard.
    TEXT

    Result = Struct.new(:url, :base64, :data_bytes, :mime_type, keyword_init: true)

    def self.conduct
      configure
      image = RubyLLM.paint(PROMPT, **Multivitamin::Models.image_paint)

      Result.new(
        url: image.url,
        base64: image.base64?,
        data_bytes: image.data&.bytesize,
        mime_type: image.mime_type
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
  Multivitamin::Cassettes.play(__dir__, "orsi_window") do
    result = IsfahanOrsiWindow::OrsiWindow.conduct
  end

  puts "url=#{result.url.inspect} base64=#{result.base64}"
end
