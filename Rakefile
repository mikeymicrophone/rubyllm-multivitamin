# frozen_string_literal: true

require "rake/testtask"

desc "Run every bottled example against its cassette"
Rake::TestTask.new(:test) do |task|
  task.test_files = FileList["features/**/*_test.rb"]
  task.warning = false
  task.verbose = true
end

task default: :test
