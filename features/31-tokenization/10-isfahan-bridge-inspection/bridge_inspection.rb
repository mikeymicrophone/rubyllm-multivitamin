# frozen_string_literal: true

# Tokenization · 10 · Isfahan bridge inspection
#
# Teaches:
# - provider_tools, provider_options, and before_request hooks are omitted from count_tokens.
# - A proc records hook execution while a pair of counts checks the same inspection question.
# - The estimate covers the ordinary request, not a future hosted search.

require_relative "../../../support/runtime"

module IsfahanBridgeInspection
  QUESTION = "Si-o-se-pol board: Leila photographs arch ISF-11 at 07:45. Which arch is assigned to Leila?"
  module_function

  def conduct
    Multivitamin::Runtime.configure(provider: :openai)
    hook_calls = []
    annotate = proc do |payload|
      hook_calls << :inspection
      payload[:metadata] = { inspection: "ISF-11" }
    end
    chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
      .with_instructions("You are the Isfahan bridge inspection clerk. Keep arch references verbatim.")
    baseline = chat.count_tokens(QUESTION)
    chat.with_provider_tools(:web_search)
      .with_provider_options(metadata: { shift: "Si-o-se-pol dawn" })
      .before_request(&annotate)
    decorated = chat.count_tokens(QUESTION)
    { baseline: baseline, decorated: decorated, hook_calls: hook_calls, roles: chat.messages.map(&:role) }
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "bridge_inspection") do
    IsfahanBridgeInspection.conduct
  end

  puts "ordinary=#{result.fetch(:baseline)} hosted setup=#{result.fetch(:decorated)} hooks=#{result.fetch(:hook_calls).length}"
end
