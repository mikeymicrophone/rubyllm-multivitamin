# frozen_string_literal: true

# Chat basics · 06 · Tallinn readiness probe check
#
# Teaches:
# - Two chats can ask the same question of two models.
# - Each chat names provider: :openai on a cheap OpenAI model.
# - with_model switches the model on a chat that already has turns,
#   and the earlier probe question stays in the transcript.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module TallinnReadinessProbe
  # SRE Kadri is on the SEPA settlement pod in Tallinn. She checks the
  # configured probe on one model, asks the spare-timeout follow-up after a
  # model switch, and asks the original question again on a fresh chat with
  # the other model.
  class ProbeCheck
    INSTRUCTIONS = <<~TEXT.strip
      You are Kadri, the SRE on the SEPA settlement pod at Lõhmus Clearing in Tallinn.
      Answer in two short sentences.
      Use only the probe notes in the conversation.
      The first sentence starts with Yes or No.
      Do not invent probe timeouts.
    TEXT

    PROBE_QUESTION = <<~TEXT.strip
      Rolling the settlement API in the Ülemiste data hall.
      The runbook on Kadri's clipboard is from https://kubernetes.io/docs/concepts/configuration/liveness-readiness-startup-probes/.
      The cluster dashboard she checked is https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/.
      Configured readiness timeout: 9 seconds.
      Cold start until :8080 binds: 8.4 seconds.
      Envoy sidecar is ready 1.5 seconds after the pod starts.
      The probe has to cover from bind down to that sidecar.
      Is the configured 9 second timeout long enough?
    TEXT

    SPARE_QUESTION = "The platform team wants the spare 6 second timeout instead of the configured one. Does that spare cover the bind?"

    Result = Struct.new(
      :mini,
      :mini_model_id,
      :spare,
      :spare_model_id,
      :switched_chat_model_id,
      :four_o,
      :four_o_model_id,
      :switched_roles,
      :fresh_roles,
      :first_user_still_present,
      keyword_init: true
    )

    def self.conduct
      configure

      mini = open_chat(Multivitamin::Models::OPENAI_CHAT)
      mini.with_instructions(INSTRUCTIONS)
      mini.with_temperature(0.2)
      mini_reply = mini.ask(PROBE_QUESTION)

      mini.with_model(
        Multivitamin::Models::OPENAI_CHAT_SWITCH,
        provider: :openai
      )
      spare_reply = mini.ask(SPARE_QUESTION)

      four_o = open_chat(Multivitamin::Models::OPENAI_CHAT_SWITCH)
      four_o.with_instructions(INSTRUCTIONS)
      four_o.with_temperature(0.2)
      four_o_reply = four_o.ask(PROBE_QUESTION)

      Result.new(
        mini: mini_reply.content,
        mini_model_id: mini_reply.model,
        spare: spare_reply.content,
        spare_model_id: spare_reply.model,
        switched_chat_model_id: mini.model.id,
        four_o: four_o_reply.content,
        four_o_model_id: four_o_reply.model,
        switched_roles: mini.messages.map(&:role),
        fresh_roles: four_o.messages.map(&:role),
        first_user_still_present: mini.messages.any? { |message|
          message.role == :user && message.content.include?("9 seconds")
        }
      )
    end

    def self.open_chat(model)
      RubyLLM.chat(model: model, provider: :openai)
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
  Multivitamin::Cassettes.play(__dir__, "probe_check") do
    result = TallinnReadinessProbe::ProbeCheck.conduct
  end

  puts "gpt-4.1-mini (#{result.mini_model_id}):"
  puts result.mini
  puts
  puts "spare after with_model (#{result.spare_model_id}):"
  puts result.spare
  puts
  puts "fresh second model (#{result.four_o_model_id}):"
  puts result.four_o
end
