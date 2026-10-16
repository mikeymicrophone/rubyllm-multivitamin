# frozen_string_literal: true

# Tokenization · 11 · Tromsø aurora proxy
#
# Teaches:
# - GPUStack tokenization uses the model proxy route without its trailing /v1.
# - assume_model_exists allows the observatory's locally deployed model name.
# - A context supplies the proxy base; each_cons inspects neighbouring token IDs.

require_relative "../../../support/runtime"

module TromsoAuroraProxy
  # The timeout scenarios bypass VCR for 127.0.0.1. Use localhost so
  # this proxy still replays when every feature shares one process.
  PROXY_BASE = "http://localhost:8080/model/proxy/7/v1"
  module_function

  def conduct
    context = RubyLLM.context do |config|
      Multivitamin::Runtime.apply(config, provider: :gpustack)
      config.gpustack_api_base = ENV.fetch("GPUSTACK_API_BASE", PROXY_BASE)
    end
    tokenization = context.tokenize(
      "Tromsø aurora board: Sigrid closes lens TRO-3 at 23:40; cloud cover 7/8.",
      model: Multivitamin::Models::GPUSTACK_TOKENIZER, provider: :gpustack, assume_model_exists: true
    )
    { tokenization: tokenization, pairs: tokenization.ids.each_cons(2).to_a,
      proxy_base: context.config.gpustack_api_base }
  end
end

if $PROGRAM_NAME == __FILE__
  result = Multivitamin::Cassettes.play(__dir__, "aurora_proxy") do
    TromsoAuroraProxy.conduct
  end

  puts "#{result.fetch(:proxy_base)}
#{result.fetch(:tokenization).count} tokens; #{result.fetch(:pairs).length} adjacent pairs"
end
