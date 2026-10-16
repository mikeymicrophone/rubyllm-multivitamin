# frozen_string_literal: true

# Evaluations · 08 · Mopti banco-brick Rake task
#
# Teaches:
# - ruby_llm:eval discovers *_evaluation.rb under app/evals.
# - Evaluation.run.save writes the JSON report the task would print.
# - The task exits unsuccessfully when a case fails; this case passes.

require "fileutils"
require "json"
require "logger"
require "stringio"
require "tmpdir"
require "ruby_llm"
require_relative "../../../support/cassettes"
require_relative "../../../support/models"

module MoptiBancoBrick
  Result = Struct.new(:report, :printed, :path, keyword_init: true)

  class BrickDesk
    def self.configure
      RubyLLM.configure do |config|
        Multivitamin::Models.configure(config, provider: :openai)
        config.max_retries = 0
        config.request_timeout = 120
        config.model_registry_file = File.expand_path("../../../tmp/ruby_llm_models.json", __dir__)
        config.logger = Logger.new(File::NULL) unless ENV["RUBYLLM_DEBUG"] == "true"
      end
    end

    def self.conduct
      configure
      require_relative "app/evals/mopti_brick_evaluation"
      output = StringIO.new
      previous = $stdout
      $stdout = output
      ENV["EVAL_OUTPUT"] = Dir.mktmpdir("mopti-brick-")
      report = MoptiBrickEvaluation.run
      path = File.join(ENV.fetch("EVAL_OUTPUT"), "MoptiBrickEvaluation.json")
      FileUtils.mkdir_p(File.dirname(path))
      report.save(path)
      puts report
      puts "Report: #{path}"
      Result.new(report: report, printed: output.string, path: path)
    ensure
      $stdout = previous if previous
    end
  end
end

if $PROGRAM_NAME == __FILE__
  result = nil
  Multivitamin::Cassettes.play(__dir__, "banco_brick") do
    result = MoptiBancoBrick::BrickDesk.conduct
  end
  puts result.printed
  puts "saved=#{result.path}"
end
