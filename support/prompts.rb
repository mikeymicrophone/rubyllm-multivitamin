# frozen_string_literal: true

module Multivitamin
  # Resolves app/prompts relative to a scenario folder. Prompt.roots is
  # process-wide, so a scenario restores the previous search path when
  # it finishes. Not scenario copy.
  module Prompts
    module_function

    def in_root(directory)
      previous = RubyLLM::Prompt.instance_variable_get(:@roots)
      RubyLLM::Prompt.instance_variable_set(:@roots, nil)
      Dir.chdir(directory) { yield }
    ensure
      RubyLLM::Prompt.instance_variable_set(:@roots, previous)
    end
  end
end
