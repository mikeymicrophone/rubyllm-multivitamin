# frozen_string_literal: true

# Configuration and contexts · 02 · Zomba exam-rubric drawer
#
# Teaches:
# - default_model is used when chat gets no model argument.
# - An explicit model on a second chat is the slug named in that call.
# - The two chats can ask the same cabinet question.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require_relative "../paid_openrouter"

module ZombaExamDrawer
  # The faculty clerk at Chancellor College in Zomba asks which drawer
  # holds the spare History oral rubric twice: once on the configured
  # default model, once on a named spare.
  class DefaultModel
    INSTRUCTIONS = <<~TEXT.strip
      You are the faculty clerk at Chancellor College in Zomba.
      Answer in two short sentences.
      Use only the cabinet list in the question.
      Quote catalog CH-17.
      Do not invent a drawer.
    TEXT

    CABINET_QUESTION = <<~TEXT.strip
      Cabinet list posted in the oral-exam office at Chancellor College, Zomba.
      College page: https://www.unima.ac.mw/.
      Drawer A: cancelled Geography rubric, cracked spine, catalog CG-4, do not issue.
      Drawer B: spare History oral rubric, catalog CH-17.
      Drawer C: six invigilator badges, catalog IB-6.
      Which drawer holds the spare History oral rubric? Quote CH-17.
    TEXT

    Result = Struct.new(
      :default_reply,
      :named_reply,
      :default_model_id,
      :named_model_id,
      :configured_default,
      :named_slug,
      keyword_init: true
    )

    def self.conduct
      configure
      default_args = chat_args
      named_args = named_chat_args

      default_chat = open_chat(default_args.except(:model))
      default_chat.with_instructions(INSTRUCTIONS)
      default_chat.with_temperature(0.2)
      default_reply = default_chat.ask(CABINET_QUESTION)

      named_chat = open_chat(named_args)
      named_chat.with_instructions(INSTRUCTIONS)
      named_chat.with_temperature(0.2)
      named_reply = named_chat.ask(CABINET_QUESTION)

      Result.new(
        default_reply: default_reply.content,
        named_reply: named_reply.content,
        default_model_id: default_reply.model,
        named_model_id: named_reply.model,
        configured_default: RubyLLM.config.default_model,
        named_slug: named_args.fetch(:model)
      )
    end

    def self.chat_args
      ConfigurationPaidOpenrouter.chat_args
    end

    def self.named_chat_args
      ConfigurationPaidOpenrouter.spare_args
    end

    def self.open_chat(args)
      ConfigurationPaidOpenrouter.prepare(RubyLLM.chat(**args))
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openrouter)
        config.default_model = chat_args.fetch(:model)
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
  Multivitamin::Cassettes.play(__dir__, "default_model") do
    result = ZombaExamDrawer::DefaultModel.conduct
  end

  puts "default #{result.default_model_id}:"
  puts result.default_reply
  puts
  puts "named #{result.named_model_id}:"
  puts result.named_reply
end
