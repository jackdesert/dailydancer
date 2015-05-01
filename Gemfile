source 'https://rubygems.org'


gem 'sinatra'
gem 'sinatra-contrib' # This provides :content_for
gem 'sinatra-subdomain'
gem 'sequel'
gem 'sqlite3' # `apt-get install libsqlite3-dev` is required on ubuntu
gem 'tzinfo'
gem 'activesupport', require: false # this provides :try
gem 'pry-byebug' # This is available in production too for debugging
gem 'rake'
gem 'thin'
gem 'haml'
gem 'rb-readline' # For some reason this is required on my Digital Ocean box under Ruby 2.1.2
gem 'chronic'
gem 'nokogiri'
gem 'redis'
gem 'mail'

group :test do
  gem 'time-warp'
  gem 'rack-test'
  gem 'database_cleaner', require: false
  gem 'rspec'
  gem 'rr', require: false
end

group :production do
  gem 'rack-cache'
end

group :development do
  gem 'rerun'
end

group :development, :test do
  gem 'guard-rspec'
  gem 'guard-livereload'
end
