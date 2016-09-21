require 'rake'
require 'bundler/gem_tasks'
begin
  require 'gemika/matrix_tasks'
rescue LoadError
  puts 'Run `gem install gemika` for additional tasks'
end

task :default => 'matrix:spec'

