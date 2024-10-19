# frozen_string_literal: true

# Using rake to bundle without test and development for packaging
# Only needed on persistent machine as CI spins up clean environment
unless ARGV[0] == 'package'
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  require 'rubocop/rake_task'

  RuboCop::RakeTask.new
end

Rake.add_rakelib 'tasks'

task default: %i[spec rubocop]
