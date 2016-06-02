

task :include_necessary_references do
  require 'bundler'
  Bundler.require(:default)
  require_relative './src/settings.rb'
  require_relative './src/res.rb'
  require_relative './src/storage.rb'
  require_relative './src/program.rb'
end

desc 'Runs program (default task)'
task main: [:include_necessary_references] do
  require 'io/console'
  require 'tzinfo'
  PasswordStore::Program.new
end

task default: :main
