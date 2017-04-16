# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ['-c', '-f progress', '-r ./spec/spec_helper.rb']
  t.pattern = 'spec/**/*_spec.rb'
end

task default: %i[rubocop spec]
