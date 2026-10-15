# frozen_string_literal: true

# Text to speech · 11 · McCurdy Point save vs to_blob
#
# Teaches:
# - Speech#to_blob returns the same bytes save writes.
# - save returns the path.
# - Both read the inline audio. Neither GETs a URL.

require "logger"
require "ruby_llm"
require "tmpdir"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module McCurdyPointSaveBlob
  # The spit clerk at McCurdy Point writes the kelp-ledge hail to a file
  # and also hands the raw bytes to the VHF desk, and those two must match.
  class McCurdyBlob
    HAIL = "McCurdy Point. Save the clip."

    Result = Struct.new(:blob, :file_bytes, :returned_path, :magic, keyword_init: true)

    def self.conduct
      configure
      speech = RubyLLM.speak(HAIL, **Multivitamin::Models.speech)
      blob = speech.to_blob
      path = File.join(Dir.mktmpdir("mccurdy-point-"), "kelp_ledge.mp3")
      returned = speech.save(path)

      Result.new(
        blob: blob,
        file_bytes: File.binread(path),
        returned_path: returned,
        magic: blob.getbyte(0)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 60
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "mccurdy_blob") do
    result = McCurdyPointSaveBlob::McCurdyBlob.conduct
  end

  puts result.blob.bytesize
  puts result.blob == result.file_bytes
end
