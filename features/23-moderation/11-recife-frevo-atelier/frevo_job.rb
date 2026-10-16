# frozen_string_literal: true

# Moderation · 11 · Recife frevo atelier
#
# Teaches:
# - A Rails-style job screens a stored photograph and writes needs_review.
# - moderate(with:) takes the file path off the record.
# - The photograph is clean, so needs_review stays false.

require "logger"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"
require "active_record"

module RecifeFrevoAtelier
  class StudioPhoto < ActiveRecord::Base
    self.table_name = "recife_studio_photos"
  end

  class ReviewPhotoJob
    SQUARE = File.expand_path("frevo-studio.png", __dir__)

    Result = Struct.new(:flagged, :needs_review, :persisted, :atelier, keyword_init: true)

    def self.conduct
      configure
      boot
      photo = StudioPhoto.create!(atelier: "Paço do Frevo loft", image_path: SQUARE, needs_review: true)
      perform(photo.id)
      photo.reload

      Result.new(
        flagged: @flagged,
        needs_review: photo.needs_review,
        persisted: photo.persisted?,
        atelier: photo.atelier
      )
    end

    def self.perform(photo_id)
      photo = StudioPhoto.find(photo_id)
      result = RubyLLM.moderate(with: photo.image_path, **Multivitamin::Models.moderation)
      @flagged = result.flagged?
      photo.update!(needs_review: result.flagged?)
    end

    def self.boot
      ActiveRecord::Base.connection_handler.clear_all_connections!
      ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
      ActiveRecord::Base.logger = Logger.new(File::NULL)
      ActiveRecord::Schema.verbose = false
      ActiveRecord::Schema.define do
        create_table :recife_studio_photos do |t|
          t.string :atelier
          t.string :image_path
          t.boolean :needs_review
        end
      end
    end

    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 60
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "frevo_job") do
    result = RecifeFrevoAtelier::ReviewPhotoJob.conduct
  end

  puts "flagged=#{result.flagged} needs_review=#{result.needs_review} atelier=#{result.atelier}"
end
