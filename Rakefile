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
        gemset_passed = block.call
        @all_passed &= gemset_passed
        if gemset_passed
          @results[gemfile] = tint('Success', COLOR_SUCCESS)
        else
          @results[gemfile] = tint('Failed', COLOR_FAILURE)
        end
      else
        @results[gemfile] = tint("Only for Ruby #{entry['rvm']}", COLOR_WARNING)
      end
    end
    print_summary
  end

  private

  def entries
    require 'yaml'
    YAML.load_file('.travis.yml')['matrix']['include'] or raise "No Travis CI matrix found in .travis.yml"
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

    gemset_size = @results.keys.collect(&:size).max
    @results.each do |gemset, result|
      puts "- #{gemset.ljust(gemset_size)}  #{result}"
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
