require 'helper'

set :port, 8856
set :raise_errors, true

# Bind to 0.0.0.0 even in development mode for access from VM
set :bind, '0.0.0.0'

# Make sure newer version of sqlite3 is used, so that HAVE_USLEEP was configured during build
if settings.production? && (SQLite3.libversion.to_s < "3008002")
  raise 'sqlite3 must be later than 3.8.0 to ensure HAVE_USLEEP was enabled during build'
end

class Dancer < Sinatra::Base

  LOG_FILE = settings.root + "/log/#{settings.environment}.log"
  error_logger = File.new(LOG_FILE, 'a')
  error_logger.sync = true

  before do
    # Note this is in a different scope than the other methods in this file
    # Link: http://spin.atomicobject.com/2013/11/12/production-logging-sinatra/
    env['rack.errors'] = error_logger if settings.production?
  end

  before do
    # Angular sends data as a bonafide POST with a JSON body, so we must catch it
    # http://stackoverflow.com/questions/12131763/sinatra-controller-params-method-coming-in-empty-on-json-post-request
    if request.content_type.try(:downcase).try(:include?, 'application/json')
      body_parameters = request.body.read
      params.merge!(JSON.parse(body_parameters))
    end
  end

  post '/messages' do
    binding.pry
  end

  def log(text)
    text = "#{text}\n"
    # In development mode, this will be written to STDOUT
    # In prouction mode, this writes to LOG_FILE
    env['rack.errors'].write(text)
  end

  def log_params
    hash = { Body: params[:Body],
             From: params[:From]}
    log("params: #{hash}")
  end

end

