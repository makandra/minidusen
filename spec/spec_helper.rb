$: << File.join(File.dirname(__FILE__), "/../../lib" )

require 'minidusen'
require 'byebug'

ActiveRecord::Base.default_timezone = :local

Dir["#{File.dirname(__FILE__)}/support/*.rb"].sort.each {|f| require f}
Dir["#{File.dirname(__FILE__)}/shared_examples/*.rb"].sort.each {|f| require f}


RSpec.configure do |config|

  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }

  config.around do |example|
    if example.metadata.fetch(:rollback, true)
      ActiveRecord::Base.transaction do
        begin
          example.run
        ensure
          raise ActiveRecord::Rollback
        end
      end
    else
      example.run
    end
  end
end
