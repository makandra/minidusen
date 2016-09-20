require 'rake'
require 'bundler/gem_tasks'

task :default => 'all:spec'

namespace :all do

  desc "Run specs for all Ruby #{RUBY_VERSION} gemfiles"
  task :spec do
    TestMatrix.new.each do
      system("bundle exec rspec spec")
    end
  end

  desc "Bundle all Ruby #{RUBY_VERSION} gemfiles"
  task :install do
    TestMatrix.new.each do
      system('bundle install')
    end
  end

  desc "Bundle all Ruby #{RUBY_VERSION} gemfiles"
  task :update do
    TestMatrix.new.each do
      system('bundle update')
    end
  end

end

class TestMatrix

  COLOR_HEAD = "\e[44;97m"
  COLOR_WARNING = "\e[33m"
  COLOR_SUCCESS = "\e[32m"
  COLOR_FAILURE = "\e[31m"
  COLOR_RESET = "\e[0m"

  def initialize
    @results = {}
    @all_passed = nil
  end

  def each(&block)
    @all_passed = true
    entries.each do |entry|
      gemfile = entry['gemfile']
      if compatible?(entry)
        print_title gemfile
        ENV['BUNDLE_GEMFILE'] = gemfile
        gemfile_passed = block.call
        @all_passed &= gemfile_passed
        if gemfile_passed
          @results[entry] = tint('Success', COLOR_SUCCESS)
        else
          @results[entry] = tint('Failed', COLOR_FAILURE)
        end
      else
        @results[entry] = tint("Skipped", COLOR_WARNING)
      end
    end
    print_summary
  end

  private

  def entries
    require 'yaml'
    travis_yml = YAML.load_file('.travis.yml')
    rubies = travis_yml.fetch('rvm')
    gemfiles = travis_yml.fetch('gemfile')
    matrix_options = travis_yml.fetch('matrix', {})
    excludes = matrix_options.fetch('exclude', [])
    entries = []
    rubies.each do |ruby|
      gemfiles.each do |gemfile|
        entry = { 'rvm' => ruby, 'gemfile' => gemfile }
        entries << entry unless excludes.include?(entry)
      end
    end
    entries
  end

  def compatible?(entry)
    entry['rvm'] == RUBY_VERSION
  end

  def tint(message, color)
    color + message + COLOR_RESET
  end

  def print_title(title)
    puts
    puts tint(title, COLOR_HEAD)
    puts
  end

  def print_summary
    print_title 'Summary'

    gemfile_size = @results.keys.map { |entry| entry['gemfile'].size }.max
    ruby_size = @results.keys.map { |entry| entry['rvm'].size }.max

    @results.each do |entry, result|
      puts "- #{entry['gemfile'].ljust(gemfile_size)}  Ruby #{entry['rvm'].ljust(ruby_size)}  #{result}"
    end

    puts

    if @all_passed
      puts tint("All gemfiles succeeded for Ruby #{RUBY_VERSION}.", COLOR_SUCCESS)
      puts
    else
      puts tint('Some gemfiles failed.', COLOR_FAILURE)
      puts
      fail
    end
  end

end
