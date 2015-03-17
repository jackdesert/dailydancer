ENV['RACK_ENV'] = 'test'

require 'sinatra'
require 'sequel'

# Set Sequel::Model to return nil if save fails, as opposed to raising an exception
#Sequel::Model.raise_on_save_failure = false

require 'pry'
require 'rspec'
require 'rr'
require 'database_cleaner'
require 'chronic'
require 'time-warp'

# DB must be defined before models are required
DB = Sequel.sqlite
# DB migrations must happen before models are loaded
# in order for the accessors to be automagically added
# (one for each database column)
Dir["#{File.dirname(__FILE__)}/../db/migrations/*.rb"].each { |f| require(f) }

require_relative '../models/util'
require_relative '../models/message'
require_relative '../models/event'
require_relative '../models/date_parser'
require_relative '../helpers/application_helper'
require_relative './support/helper_methods'

RSpec.configure do |config|
  config.mock_with :rr

  # Allow running one test at a time
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true




  config.before(:suite) do
    # set the strategy that will be used in DatabaseCleaner.cleaning
    DatabaseCleaner.strategy = :transaction

    # Clean once with truncation at the beginning of specs
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.expect_with(:rspec) { |c| c.syntax = [:should, :expect] }


end

