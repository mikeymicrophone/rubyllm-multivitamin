# frozen_string_literal: true

# Models and providers · 07 · Bobo-Dioulasso shea-kernel catalogs
#
# Teaches:
# - embedding_models and chat_models do not overlap on id and provider.
# - type :embedding versus type :chat is the split, not a substring of the id.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"

module BoboShea
  # The kernel clerk in Bobo-Dioulasso keeps the vector catalog of
  # tasting notes apart from the chat clerks who answer the gatherers,
  # the way a kernel book is not the same drawer as the radio log.
  class KernelCatalog
    Result = Struct.new(
      :chat_count,
      :embedding_count,
      :overlap,
      :id_only_overlap,
      :embedding_sample_id,
      :embedding_sample_type,
      :embedding_sample_provider,
      :embedding_in_chat,
      :chat_sample_id,
      :chat_sample_type,
      :chat_in_embedding,
      keyword_init: true
    )

    def self.conduct
      configure

      chats = RubyLLM.models.chat_models
      embeddings = RubyLLM.models.embedding_models
      chat_keys = chats.map { |model| [model.id, model.provider] }
      embedding_keys = embeddings.map { |model| [model.id, model.provider] }
      embedding = RubyLLM.models.find("text-embedding-3-small")
      chat = RubyLLM.models.find("gpt-4.1-mini", provider: :openai)

      Result.new(
        chat_count: chats.count,
        embedding_count: embeddings.count,
        overlap: (chat_keys & embedding_keys),
        id_only_overlap: (chats.map(&:id) & embeddings.map(&:id)),
        embedding_sample_id: embedding.id,
        embedding_sample_type: embedding.type,
        embedding_sample_provider: embedding.provider,
        embedding_in_chat: chats.any? { |model|
          model.id == embedding.id && model.provider == embedding.provider
        },
        chat_sample_id: chat.id,
        chat_sample_type: chat.type,
        chat_in_embedding: embeddings.any? { |model|
          model.id == chat.id && model.provider == chat.provider
        }
      )
    end

    def self.configure
      RubyLLM.configure do |config|
        config.max_retries = 0
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "kernel_catalog") do
    result = BoboShea::KernelCatalog.conduct
  end

  puts "chat #{result.chat_count} embedding #{result.embedding_count} overlap #{result.overlap.size}"
  puts "#{result.embedding_sample_id} type=#{result.embedding_sample_type}"
end
