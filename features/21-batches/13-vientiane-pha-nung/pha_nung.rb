# frozen_string_literal: true

# Batches · 13 · Vientiane pha-nung desk capstone
#
# Teaches:
# - A desk can stage two chats, submit, find, and refresh once.
# - statuses is empty until results arrive; messages keeps one slot per chat.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module VientianePhaNung
  class NungDesk
    INSTRUCTIONS = <<~TEXT.strip
      You are the cloth clerk at the pha nung loft in Vientiane.
      Answer in one short sentence from the card only.
      Name 19 lengths and Khamla.
    TEXT

    COUNT = <<~TEXT.strip
      Vientiane pha nung loft card, Friday 16 October 2026.
      19 lengths on the east beam. Khamla folds the next hem.
      How many lengths sit on the beam?
    TEXT

    FOLD = <<~TEXT.strip
      Vientiane pha nung loft card, Friday 16 October 2026.
      Khamla folds the next hem at 15:10.
      Who folds the next hem?
    TEXT

    Result = Struct.new(
      :submitted_id,
      :found_id,
      :status,
      :complete,
      :message_slots,
      :statuses,
      keyword_init: true
    )

    def self.conduct
      configure
      chats = [
        open_chat.with_instructions(INSTRUCTIONS).with_temperature(0.2).ask_later(COUNT),
        open_chat.with_instructions(INSTRUCTIONS).with_temperature(0.2).ask_later(FOLD)
      ]
      submitted = RubyLLM.batch(chats)
      found = RubyLLM::Batch.find(submitted.id, provider: :openai)
      found.refresh
      slots = found.messages
      Result.new(
        submitted_id: submitted.id,
        found_id: found.id,
        status: found.status,
        complete: found.complete?,
        message_slots: slots.size,
        statuses: found.statuses
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

    def self.open_chat(model: nil)
      kwargs = Multivitamin::Models.chat(provider: :openai)
      kwargs = kwargs.merge(model: model) if model
      chat = RubyLLM.chat(**kwargs)
      Multivitamin::Models.quiet_thinking(chat, provider: :openai)
      chat
    end

  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "pha_nung") do
    result = VientianePhaNung::NungDesk.conduct
  end
  puts "id=#{result.found_id} status=#{result.status} slots=#{result.message_slots}"
end
