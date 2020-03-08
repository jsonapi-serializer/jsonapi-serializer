require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

desc('Codestyle check and linter')
RuboCop::RakeTask.new('rubocop') do |task|
  task.fail_on_error = true
  task.patterns = [
    'lib/**/*.rb',
    'spec/**/*.rb'
  ]
end

RSpec::Core::RakeTask.new(:spec)
task(default: [:rubocop, :spec])
