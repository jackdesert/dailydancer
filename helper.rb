require 'sinatra'
require 'pry'
require 'sequel'
require 'json'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/blank'
require 'chronic'
require 'nokogiri'

# Note you must connect to Sequel before requiring any models that inherit from Sequel::Model
unless settings.test?
  DB_FILE = "./db/#{settings.environment}.db"
  DB = Sequel.connect("sqlite://#{DB_FILE}", max_connections: 8)
end

require './models/util'
require './models/date_parser'
require './models/message'
require './models/event'
require './helpers/application_helper'

