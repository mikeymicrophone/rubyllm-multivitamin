# frozen_string_literal: true

# Chat basics · 12 · Accession tag for the Singapore Botanic Gardens
#
# Teaches:
# - A tight with_max_output_tokens can come back empty or too short to post.
# - The clerk reads content and max_tokens? before trusting the note.
# - response.raw.status is the HTTP status beside the parsed message.
# - When the note is too short, a second ask on the same chat asks for
#   the correction in full, with the cap cleared.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module SingaporeAccession
  # The herbarium clerk's correction slip for sheet SBG-18465 is long enough to post.
  # The first ask is capped so the note may come back clipped. The clerk
  # only posts a note that has room to name the sheet and the tag.
  class AccessionNotice
    INSTRUCTIONS = <<~TEXT.strip
      You are the herbarium clerk correcting sheet SBG-18465 at the Singapore Botanic Gardens.
      Use only the correction slip in this chat.
      Name sheet SBG-18465 and tag DH.
      Do not invent a latitude or a longitude.
    TEXT

    SLIP_QUESTION = <<~TEXT.strip
      Correction slip SBG-18465, copied for the living collection on Wednesday 14 October 2026.
      Gardens catalog: https://www.nparks.gov.sg/sbg.
      Herbarium desk the clerk copied from: https://www.nparks.gov.sg/.
      Sheet SBG-18465, Singapore Botanic Gardens.
      Living-collection tag DH for the Shorea specimen is moved 300 cm northwest of the painted bed mark.
      The old mark is still painted. Do not use it for a GPS pin.
      The slip gives no new latitude and no new longitude.
      Write the correction the gardeners can pencil on the bed plan: two sentences, the sheet number, the tag, and the 300 cm move.
    TEXT

    REST_QUESTION = "That note was too short to pencil on the bed plan. Write the correction in two sentences. Name sheet SBG-18465 and tag DH and the 300 cm move."

    CLIP = 64
    SHORT_LENGTH = 80

    Result = Struct.new(
      :clipped_content,
      :clipped_thinking,
      :clipped_finish,
      :clipped_max_tokens,
      :clipped_status,
      :asked_again,
      :posted_content,
      :posted_status,
      :posted_finish,
      :roles,
      keyword_init: true
    )

    def self.conduct
      configure

      chat = RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
      )
      chat.with_instructions(INSTRUCTIONS)
      chat.with_temperature(0.2)
      chat.with_max_output_tokens(CLIP)

      clipped = chat.ask(SLIP_QUESTION)
      clipped_text = clipped.content.to_s.strip
      short_note = clipped_text.empty? || clipped.max_tokens? || clipped_text.length < SHORT_LENGTH

      if short_note
        chat.with_max_output_tokens(nil)
        posted = chat.ask(REST_QUESTION)
        asked_again = true
      else
        posted = clipped
        asked_again = false
      end

      Result.new(
        clipped_content: clipped.content,
        clipped_thinking: clipped.thinking&.text,
        clipped_finish: clipped.finish_reason,
        clipped_max_tokens: clipped.max_tokens?,
        clipped_status: clipped.raw.status,
        asked_again: asked_again,
        posted_content: posted.content,
        posted_status: posted.raw.status,
        posted_finish: posted.finish_reason,
        roles: chat.messages.map(&:role)
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY")
        config.openrouter_app_url = "https://github.com/mikeymicrophone/rubyllm-multivitamin"
        config.openrouter_app_name = "RubyLLM Multivitamin"
        # Chat Completions emits a developer role unless this is set.
        # OpenRouter expects system. The flag is shared with OpenAI's formatter.
        config.openai_use_system_role = true
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
  Multivitamin::Cassettes.play(__dir__, "accession_notice") do
    result = SingaporeAccession::AccessionNotice.conduct
  end

  puts "clipped finish=#{result.clipped_finish} max_tokens=#{result.clipped_max_tokens} " \
       "status=#{result.clipped_status} chars=#{result.clipped_content.to_s.length} asked_again=#{result.asked_again}"
  puts result.clipped_content.inspect
  puts
  puts "posted finish=#{result.posted_finish} status=#{result.posted_status}"
  puts result.posted_content
end
