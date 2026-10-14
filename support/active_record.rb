# frozen_string_literal: true

require "active_record"
require "logger"
require "ruby_llm"

require "ruby_llm/active_record/record"
require "ruby_llm/active_record/payload_helpers"
require "ruby_llm/active_record/model"
require "ruby_llm/active_record/tool_call"
require "ruby_llm/active_record/usage"
require "ruby_llm/active_record/batch"
require "ruby_llm/active_record/mcp_credential"
require "ruby_llm/active_record/provider_file"
require "ruby_llm/active_record/chat_methods"
require "ruby_llm/active_record/message_methods"
require "ruby_llm/active_record/acts_as"

unless ActiveRecord::Base.included_modules.include?(RubyLLM::ActiveRecord::ActsAs)
  ActiveRecord::Base.include RubyLLM::ActiveRecord::ActsAs
end

module Multivitamin
  # Boots an in-memory SQLite schema for a Rails-integration scenario.
  # Table names come from the caller. This file must not mention a
  # station, a boat, or a cabinet.
  module ActiveRecordBoot
    module_function

    def prepare!(chat_table:, message_table:, message_foreign_key:)
      connect!
      define_schema!(
        chat_table: chat_table,
        message_table: message_table,
        message_foreign_key: message_foreign_key
      )
      wire_ruby_llm!
    end

    def connect!
      ActiveRecord::Base.connection_handler.clear_all_connections!
      ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
      ActiveRecord::Base.logger = Logger.new(File::NULL)
    end

    def define_schema!(chat_table:, message_table:, message_foreign_key:)
      ActiveRecord::Schema.verbose = false
      ActiveRecord::Schema.define do
        create_table :ruby_llm_models do |t|
          t.string :model_id, null: false
          t.string :name, null: false
          t.string :provider, null: false
          t.string :family
          t.datetime :model_created_at
          t.integer :context_window
          t.integer :max_output_tokens
          t.date :knowledge_cutoff
          t.datetime :unlisted_at
          t.json :modalities, default: {}
          t.json :capabilities, default: []
          t.json :pricing, default: {}
          t.json :metadata, default: {}
          t.timestamps
          t.index %i[provider model_id], unique: true
        end

        create_table :ruby_llm_tool_calls do |t|
          t.references :message, polymorphic: true, null: false, index: false
          t.references :result, polymorphic: true, index: false
          t.string :tool_call_id, null: false
          t.string :name, null: false
          t.text :thought_signature
          t.string :approval
          t.boolean :remote, default: false, null: false
          t.json :arguments, default: {}
          t.json :mcp_state
          t.json :mcp_result
          t.timestamps
          t.index %i[message_type message_id]
          t.index %i[result_type result_id]
          t.index :tool_call_id, unique: true
        end

        create_table :ruby_llm_usages do |t|
          t.references :chat, polymorphic: true, index: false
          t.references :message, polymorphic: true, index: false
          t.references :owner, polymorphic: true, index: false
          t.string :operation, null: false
          t.string :provider, null: false
          t.string :model, null: false
          t.string :status, null: false
          t.integer :input_tokens
          t.integer :output_tokens
          t.integer :cache_read_tokens
          t.integer :cache_write_tokens
          t.integer :thinking_tokens
          t.json :server_tool_use
          t.decimal :input_cost, precision: 16, scale: 10
          t.decimal :output_cost, precision: 16, scale: 10
          t.decimal :cache_read_cost, precision: 16, scale: 10
          t.decimal :cache_write_cost, precision: 16, scale: 10
          t.decimal :thinking_cost, precision: 16, scale: 10
          t.decimal :total_cost, precision: 16, scale: 10
          t.timestamps
          t.index %i[chat_type chat_id]
          t.index %i[message_type message_id]
          t.index %i[owner_type owner_id]
        end

        create_table :ruby_llm_batches do |t|
          t.string :provider_batch_id, null: false
          t.string :provider, null: false
          t.string :status, null: false
          t.string :raw_status
          t.boolean :completed, null: false, default: false
          t.string :chat_type
          t.string :batch_protocol
          t.json :chat_ids, default: []
          t.json :request_counts
          t.json :reported_cost
          t.timestamps
        end

        create_table :ruby_llm_mcp_credentials do |t|
          t.references :owner, polymorphic: true
          t.string :key, null: false
          t.text :data
          t.timestamps
          t.index :key, unique: true
        end

        create_table :ruby_llm_provider_files do |t|
          t.string :blob_key, null: false
          t.string :provider, null: false
          t.string :account, null: false
          t.text :file_id, null: false
          t.datetime :expires_at
          t.timestamps
        end

        create_table chat_table do |t|
          t.references :ruby_llm_model, null: false, foreign_key: { to_table: :ruby_llm_models }
          t.boolean :cancelled, null: false, default: false
          t.timestamps
        end

        create_table message_table do |t|
          t.references chat_table.to_s.singularize, null: false,
                       foreign_key: { to_table: chat_table },
                       index: { name: "index_#{message_table}_on_#{message_foreign_key}" }
          t.string :role, null: false
          t.text :content
          t.boolean :cache_until_here, null: false, default: false
          t.string :cache_ttl
          t.text :thinking_text
          t.text :thinking_signature
          t.json :citations
          t.json :server_tool_calls
          t.json :raw_content
          t.json :raw_reasoning
          t.string :finish_reason
          t.timestamps
        end
      end
    end

    def wire_ruby_llm!
      RubyLLM.config.mcp_credential_store ||= RubyLLM::ActiveRecord::MCPCredential
      RubyLLM::Accounting::Usage.ledger ||= RubyLLM::ActiveRecord::Usage

      ActiveRecord::Base.descendants.each do |klass|
        next if klass.abstract_class?

        klass.reset_column_information
      rescue ActiveRecord::StatementInvalid
        nil
      end
    end

    def seed_model(model_id:, provider:)
      RubyLLM::ActiveRecord::Model.find_or_create_by!(model_id: model_id, provider: provider.to_s) do |row|
        row.name = model_id
        row.capabilities = []
        row.modalities = {}
        row.pricing = {}
        row.metadata = {}
      end
    end
  end
end
