# frozen_string_literal: true

# Tokenization · 09 · Luang Prabang ferry ledger
#
# Teaches:
# - Count a staged request, then complete it and read billed response.tokens separately.
# - after_message runs for generation, not the counting request.
# - A lambda snapshots callbacks; zip/sum totals the separately named usage buckets.

require_relative "../../../support/runtime"

module LuangPrabangFerryLedger
  Ledger = Data.define(:estimate, :input, :output, :total, :brief, :before_callbacks, :callbacks, :roles)
  module_function

  def conduct
    Multivitamin::Runtime.configure(provider: :openai)
    callbacks = []
    snapshot = -> { callbacks.dup }
    chat = RubyLLM.chat(model: Multivitamin::Models::OPENAI_CHAT, provider: :openai)
      .with_instructions("You are the Luang Prabang ferry clerk. Answer from the landing board in one sentence.")
    chat.after_message { |message| callbacks << message.role }
    chat.ask_later("Ban Xieng Mene landing: Kham holds ferry LPB-6 until 10:25. When can LPB-6 leave?")
    estimate = chat.count_tokens
    before_callbacks = snapshot.call
    response = chat.complete
    usage = %i[input output].zip([response.tokens.input, response.tokens.output]).to_h
    Ledger.new(estimate: estimate, input: usage.fetch(:input), output: usage.fetch(:output),
      total: usage.values.sum, brief: response.content, before_callbacks: before_callbacks,
      callbacks: snapshot.call, roles: chat.messages.map(&:role))
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "ferry_ledger") do
    LuangPrabangFerryLedger.conduct
  end

  puts result.brief
  puts "estimate=#{result.estimate} billed input=#{result.input} output=#{result.output} total=#{result.total}"
end
