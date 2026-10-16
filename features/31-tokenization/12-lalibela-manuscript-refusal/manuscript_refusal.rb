# frozen_string_literal: true

# Tokenization · 12 · Lalibela manuscript refusal
#
# Teaches:
# - OpenAI has no plain-text tokenizer; OpenRouter Chat Completions has no counting endpoint.
# - Rescue RubyLLM::Error per operation without substituting a character estimate.
# - case/in classifies failures; no HTTP request or cassette is needed.

require_relative "../../../support/runtime"

module LalibelaManuscriptRefusal
  QUESTION = "Lalibela manuscript desk: Dawit checks folio LAL-9 at 11:15. Which folio is reserved?"
  module_function

  def conduct
    Multivitamin::Runtime.configure(provider: :openai)
    Multivitamin::Runtime.configure(provider: :openrouter)
    attempts = {
      inscription_ids: -> { RubyLLM.tokenize(QUESTION, model: Multivitamin::Models::OPENAI_CHAT, provider: :openai) },
      request_count: -> {
        RubyLLM.chat(model: Multivitamin::Models::CHAT, provider: :openrouter, assume_model_exists: true)
          .count_tokens(QUESTION)
      }
    }
    attempts.each_with_object({}) do |(operation, attempt), refusals|
      begin
        attempt.call
        raise "Manuscript desk expected an unsupported operation: #{operation}"
      rescue RubyLLM::Error => refusal
        capability = case refusal.message
        in /text tokenization/
          :plain_text_ids
        in /token counting/
          :request_count
        end
        refusals[operation] = { error: refusal, message: refusal.message, capability: capability }
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "manuscript_refusal") do
    LalibelaManuscriptRefusal.conduct
  end

  result.each { |operation, refusal| puts "#{operation}: #{refusal.fetch(:message)}" }
end
