require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/subdomain'
require 'rack/cache'
require 'redis'
require 'pry'
require 'sequel'
require 'json'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/object/blank'
require 'chronic'
require 'nokogiri'
require 'yaml'
require 'mail'
require 'open-uri'
require 'mechanize'

# Note you must connect to Sequel before requiring any models that inherit from Sequel::Model
unless settings.test?
  DB_FILE = "./db/#{settings.environment}.db"
  DB = Sequel.connect("sqlite://#{DB_FILE}")
end

require './models/util'
require './models/ledger'
require './models/date_parser'
require './models/message'
require './models/event'
require './models/faisbook_event'
require './mailers/mailer'
require './helpers/application_helper'
require './presenters/message_presenter'

