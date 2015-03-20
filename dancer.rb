require './helper'

# Set port 8852 using rackup when in production mode to match nginx config
# set :port, 8852
set :raise_errors, true

# Bind to 0.0.0.0 even in development mode for access from VM
# If it does not bind properly, use `-o 0.0.0.0` from command line
set :bind, '0.0.0.0'

# Make sure newer version of sqlite3 is used, so that HAVE_USLEEP was configured during build
if settings.production? && (SQLite3.libversion.to_s < "3008002")
  raise 'sqlite3 must be later than 3.8.0 to ensure HAVE_USLEEP was enabled during build'
end

class Dancer < Sinatra::Base
  include ApplicationHelper

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

  before do
    redirect_if_www
  end

  get '/' do
    locals = { date_range_with_messages: Message.by_date(7),
                page_title: 'Daily Dancer',
                nav_class: :home
              }

    haml :'messages/index_by_date', locals: locals
  end

  get '/faq' do
    haml :'pages/faq', locals: {page_title: 'Daily Dancer', nav_class: :faq}
  end

  get '/admin/messages' do
    locals = { messages: Message.order(Sequel.desc(:id)) }
    haml :'admin/messages/index', locals: locals, layout: false
  end

  post '/messages' do
    author = params['headers'].try(:[], 'From' )
    subject = params['headers'].try(:[], 'Subject')

    # either html or plain must be present to have a meaningful message
    plain = params['plain'] || ''
    html  = params['html']  || ''

    message = Message.new(author: author,
                          subject: subject,
                          plain: plain,
                          html: html)

    if message.valid?
      message.save
      status 201
      message.values.to_json
    else
      log_params
      status 400
    end
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

  def redirect_if_www
    www_regex = /\Awww\./
    http_host = env['HTTP_HOST']

    if http_host.match www_regex
      naked_http_host = http_host.sub(www_regex, '')
      redirect "http://#{naked_http_host}"
    end
  end

end

