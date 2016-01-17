require 'open-uri'
require 'mechanize'
require 'pry'

class FaisbookEvent < Sequel::Model

  CONFIG          = YAML.load_file('config/faisbook.yml')
  DOMAIN          = CONFIG['domain']
  EMAIL           = CONFIG['email']
  PASSWORD        = CONFIG['password']
  ACCESS_TOKEN    = CONFIG['access_token']
  ACTUAL_NAME     = CONFIG['actual_name']

  NUM_PAGES = 10

  plugin :validation_helpers

  def validate
    super
    validates_presence :faisbook_id
    validates_unique :faisbook_id
  end

  def before_create
    now = DateTime.now
    self.created_at = now
    self.updated_at = now
    super
  end

  def before_save
    self.updated_at = DateTime.now
    super
  end

  def link
    "http://#{DOMAIN}/#{faisbook_id}"
  end

  def address_link
    return nil if address.nil?
    "http://maps.google.com/maps?q=#{address.gsub(' ', '+')}"
  end

  def when
    start_datetime = DateTime.parse(start_time)
    end_datetime = DateTime.parse(end_time)

    if start_datetime.minute + end_datetime.minute == 0
      # "2pm" if no minutes
      format_string = '%l%P'
    else
      # "2:30pm" if minutes
      format_string = '%l:%M%P'
    end

    start_time_formatted = start_datetime.strftime(format_string)
    end_time_formatted   = end_datetime.strftime(format_string)

    if start_datetime.to_date == end_datetime.to_date
      "#{start_time_formatted} - #{end_time_formatted}"
    else
      start_time_formatted
    end
  end

  def self.visible
    # Visible is used to denote those that have all their fields fetched.
    where("name IS NOT NULL")
  end

  def self.invisible
    # Visible is used to denote those that have all their fields fetched.
    where("name IS NULL")
  end

  def self.future
    visible.where("date >= '#{Util.current_date_in_portland}'")
  end

  def self.last_update
    future.order(:updated_at).last.try(:updated_at)
  end

  def self.last_create
    future.order(:created_at).last.try(:created_at)
  end

  def self.order_columns
    [:date, :name]
  end

  def self.date_column
    :date
  end

  def self.agent
    return @agent if @agent
    @agent = Mechanize.new

    # Set user agent so they don't think we're scraping ;)
    @agent.user_agent_alias = 'Mac Safari'
    @agent
  end

  def self.logout
    # Clear agent so we can access the login page
    @agent = nil
  end

  def self.login_page
    # Using faisbook's mobile-optimized site because it does not depend on Javascript!
    agent.get("http://m.#{DOMAIN}/")
  end

  def self.dance_page
    # Using faisbook's mobile-optimized site because it does not depend on Javascript!
    agent.get("http://m.#{DOMAIN}/groups/sacredcircledance")
  end

  def self.login
    logout
    # Note that only string values are recognized in params
    form = login_page.forms.first
    email_field = form.field_with(name: 'email')
    email_field.value = EMAIL
    password_field = form.field_with(name: 'pass')
    password_field.value = PASSWORD

    form.submit
  end

  def self.scrape_event_ids(num_pages=NUM_PAGES)
    login

    faisbook_ids = []

    page = dance_page

    num_pages.times do |index|

      if index > 0
        page = page.link_with(text: 'See More Posts').click
      end

      links = page.links_with(:href => %r{/events/\d+})

      links.each do |link|
        link.uri.to_s.match(/\/events\/(\d+)/)
        faisbook_ids << $1
      end

      puts faisbook_ids.uniq.count
    end

    faisbook_ids.uniq
  end

  def self.fetch_event_details_from_api(faisbook_ids=nil)
    events = []

    if faisbook_ids.nil?
      faisbook_ids = scrape_event_ids
    end

    faisbook_ids.each do |faisbook_id|
      url = "https://graph.#{DOMAIN}/v2.5/#{faisbook_id}?access_token=#{ACCESS_TOKEN}"
      result = begin
                open(url).read
               rescue OpenURI::HTTPError
                 puts "Unable to read event_id #{faisbook_id}"
                 {id: faisbook_id}.to_json
               end

      unless result.nil?
        events << JSON.parse(result)
      end
    end

    events
  end

  def self.date_from_datetime_string(datetime_string)
    return nil if datetime_string.nil?
    datetime_string[0..9]
  end

  def self.save_event(json_event)
    faisbook_id = json_event['id']
    new_event = find(faisbook_id: faisbook_id) || new

    new_event.faisbook_id = faisbook_id

    if json_event.keys.count > 1
      # Events that fetched correctly from the API will have
      # all the required keys. Events that did not fetch
      # will come through only with "id"
      new_event.name = json_event['name']
      new_event.description = json_event['description']

      new_event.location = json_event['place'].try(:[], 'name')

      json_location = json_event['place'].try(:[], 'location')

      if json_location
        # Occasionally events do not have a location. Go figure
        new_event.address = "#{json_location['street']} #{json_location['city']} #{json_location['state']}"
      end

      new_event.start_time = json_event['start_time']
      new_event.end_time = json_event['end_time']
      new_event.date = date_from_datetime_string(json_event['end_time'])
      puts "saving event"
    else
      puts "saving placeholder event"
    end

    begin
    new_event.save unless new_event.changed_columns.empty?
    rescue
      binding.pry
    end
  end

  def self.save_json_events(json_events)
    # json_events are processed in reverse order
    # so that if anything goes wrong, the one that broke
    # is right next to the newest good one in database
    json_events.reverse.each do |json_event|
      save_event(json_event)
    end
  end

  def self.fetch_and_save_newly_posted
    json_events = fetch_event_details_from_api

    save_json_events(json_events)

    nil
  end

  def self.update_future_events
    faisbook_ids = future.all.map(&:faisbook_id)

    json_events = fetch_event_details_from_api(faisbook_ids)

    save_json_events(json_events)

    nil
  end


end



