# frozen_string_literal: true

# Chat basics · 11 · Net loft mending ticket
#
# Teaches:
# - Two chats, two personas, two with_instructions strings.
# - One persona's transcript grows turn by turn: each say adds a user
#   message and an assistant message.
# - The other persona never sees those later turns.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module AnacortesNetLoft
  # Hattie runs the loft. Calder skips the seiner. They read one ticket
  # from two chats, and only Hattie's chat hears the belly tear grow.
  class MendingTicket
    LOFT_INSTRUCTIONS = <<~TEXT.strip
      You are Hattie, the loft boss at the net loft beside the Port of Anacortes marina.
      The marina is https://www.portofanacortes.com/.
      Answer in two short sentences.
      Use only ticket NL-214 and the corrections in this chat.
      Name the twine numbers.
      Do not mend the herring bait bag.
    TEXT

    SKIPPER_INSTRUCTIONS = <<~TEXT.strip
      You are Calder, skipper of the seiner Cape Flattery.
      Speak as the skipper, in two short sentences, telling the loft what to mend.
      Use only ticket NL-214.
      The first sentence must contain NL-214.
      Do not mention a mesh count that is not on the ticket.
    TEXT

    TICKET_QUESTION = <<~TEXT.strip
      Mending ticket NL-214 for the seiner Cape Flattery, tied at the Port of Anacortes marina.
      Tear 1: cork line, 14 meshes, starboard shoulder, twine 36.
      Tear 2: lead line, 6 meshes, belly, twine 48.
      The herring bait bag is not on this ticket.
      Hattie, which tear do you mend first, and what twine?
    TEXT

    BELLY_QUESTION = <<~TEXT.strip
      Calder just hailed the loft.
      The belly tear grew from 6 meshes to 9 meshes.
      The cork-line tear is unchanged.
      Answer in two sentences.
      The first sentence must contain 9 and twine 48.
      The second sentence must contain twine 36.
    TEXT

    SKIPPER_QUESTION = <<~TEXT.strip
      Mending ticket NL-214 for your seiner Cape Flattery.
      Tear 1: cork line, 14 meshes, starboard shoulder, twine 36.
      Tear 2: lead line, 6 meshes, belly, twine 48.
      Tell the loft which tear to mend first.
    TEXT

    Result = Struct.new(
      :first_mend,
      :after_the_hail,
      :skipper,
      :loft_lengths,
      :skipper_length,
      :loft_roles,
      :skipper_roles,
      :loft_instructions,
      :skipper_instructions,
      :belly_hail_on_the_loft_chat,
      :belly_hail_on_the_skipper_chat,
      keyword_init: true
    )

    def self.conduct
      configure

      loft = open_chat
      loft.with_instructions(LOFT_INSTRUCTIONS)
      loft.with_temperature(0.2)
      first = loft.ask(TICKET_QUESTION)
      after_first = loft.messages.length
      hail = loft.ask(BELLY_QUESTION)
      after_hail = loft.messages.length

      skipper = open_chat
      skipper.with_instructions(SKIPPER_INSTRUCTIONS)
      skipper.with_temperature(0.2)
      skipper_reply = skipper.ask(SKIPPER_QUESTION)

      Result.new(
        first_mend: first.content,
        after_the_hail: hail.content,
        skipper: skipper_reply.content,
        loft_lengths: [after_first, after_hail],
        skipper_length: skipper.messages.length,
        loft_roles: loft.messages.map(&:role),
        skipper_roles: skipper.messages.map(&:role),
        loft_instructions: loft.messages.find { |message| message.role == :system }.content,
        skipper_instructions: skipper.messages.find { |message| message.role == :system }.content,
        belly_hail_on_the_loft_chat: loft.messages.any? { |message|
          message.role == :user && message.content.include?("9 meshes")
        },
        belly_hail_on_the_skipper_chat: skipper.messages.any? { |message|
          message.content.to_s.include?("9 meshes")
        }
      )
    end

    def self.open_chat
      RubyLLM.chat(
        model: Multivitamin::Models::CHAT,
        provider: :openrouter,
        assume_model_exists: true
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
  Multivitamin::Cassettes.play(__dir__, "mending_ticket") do
    result = AnacortesNetLoft::MendingTicket.conduct
  end

  puts "Hattie, first:"
  puts result.first_mend
  puts
  puts "Hattie, after the hail (transcript lengths #{result.loft_lengths.join(" then ")}):"
  puts result.after_the_hail
  puts
  puts "Calder:"
  puts result.skipper
end
