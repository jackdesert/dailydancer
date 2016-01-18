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
  helpers Sinatra::ContentFor
  register Sinatra::Subdomain

  BASELINE_DAYS = 7
  ADDITIONAL_DAYS = 24

  PRODUCTION = 'pdxdailydancer.com'
  STAGING = 'pdxdailydancer-staging.com'

  CANONICAL_SERVER_NAMES = [PRODUCTION, STAGING]

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
    redirect_to_canonical_url
  end

  subdomain :status do
    get '/' do

    locals  = { system_errors: system_errors,
                last_ingestion_in_hours: last_ingestion_in_hours,
                num_events: Event.count,
                num_messages: Message.count,
                unique_visitors_today: Ledger.party_size,
                page_title: 'Daily Dancer',
                nav_class: :status }

      haml :'status', locals: locals
    end
  end

  get '/' do


    browser = Util.is_browser?(env['HTTP_USER_AGENT'])
    show_duplicates = admin = !!params[:admin]
    allow_cache = !!params[:allow_cache]

    if browser
      Ledger.record_guest(env['HTTP_X_REAL_IP'])
    end

    cache_text = 'no cache'
    if (browser && settings.production? && !admin) || allow_cache
      # Only cache things for browsers, since we don't care as much about response time for crawlers
      # and crawlers don't request any messages so they don't take that long
      cache_control :public
      the_etag = build_etag
      etag the_etag, :weak # Using a weak etag so our patched version of nginx does not strip it out
      cache_text = "cache: #{Time.now}, etag: #{the_etag}"
    end


    xhr = !!params[:xhr]
    if xhr
      num_days = ADDITIONAL_DAYS
      offset = BASELINE_DAYS
    else
      num_days = BASELINE_DAYS
      offset = 0
    end

    if browser
      date_range_with_messages        = MessagePresenter.by_date_deduplicated(num_days, offset, show_duplicates)
      date_range_with_faisbook_events = Util.by_date(FaisbookEvent, num_days, offset)
    else
      date_range_with_messages        = Util.by_date_empty(num_days, offset)
      date_range_with_faisbook_events = Util.by_date_empty(num_days, offset)
    end

    # Note Event has its own by_date method (not the common Util.by_date)
    date_range_with_events = Event.by_date(num_days, offset)

    # For next time
    Event.load_in_thread_if_its_been_a_while

    locals  = { date_range_with_messages: date_range_with_messages,
                date_range_with_events: date_range_with_events,
                date_range_with_faisbook_events: date_range_with_faisbook_events,
                page_title: 'Daily Dancer',
                nav_class: :root,
                admin: admin,
                xhr: xhr
              }

    haml :'messages/index_by_date', locals: locals, layout: !xhr
    #cache_text
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
      confirm_listing(message)
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

  def redirect_to_canonical_url

    return unless settings.production?

    server_name = env['SERVER_NAME']
    server_name = server_name.sub('status.', '') if server_name

    unless CANONICAL_SERVER_NAMES.include?(server_name)
      redirect "http://#{PRODUCTION}"
    end
  end

  def confirm_listing(message)
    thread = Thread.new do
      email = Mailer.confirm_listing(message)
      email.deliver if email
    end

    # Do not wait in production --- It's faster that way
    # (though we will not know about errors)
    thread.join unless settings.production?
  end

end

