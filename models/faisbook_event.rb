require 'open-uri'
require 'mechanize'
require 'pry'

class FaisbookEvent < Sequel::Model

  CONFIG          = YAML.load_file('config/faisbook.yml')
  DOMAIN          = CONFIG['domain']
  EMAIL           = CONFIG['email']
  PASSWORD        = CONFIG['password']
  ACTUAL_NAME     = CONFIG['actual_name']

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
    "http://maps.google.com/maps?q=#{address.gsub(' ', '+')}"
  end

  def when
    start_datetime = DateTime.parse(start_time)
    end_datetime = DateTime.parse(end_time)

    format_string = '%l%P'
    start_time_formatted = start_datetime.strftime(format_string)
    end_time_formatted   = end_datetime.strftime(format_string)

    if start_datetime.to_date == end_datetime.to_date
      "#{start_time_formatted} - #{end_time_formatted}"
    else
      start_time_formatted
    end
  end

  def self.visible
    where('')
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

  def self.scrape_event_ids
    logout
    # Note that only string values are recognized in params
    form = login_page.forms.first
    email_field = form.field_with(name: 'email')
    email_field.value = EMAIL
    password_field = form.field_with(name: 'pass')
    password_field.value = PASSWORD

    form.submit

    links = dance_page.links_with(:href => %r{/events/\d+})
    event_ids = links.map do |link|
      link.uri.to_s.match(/\/events\/(\d+)/)
      $1
    end

    event_ids.uniq
  end

  def self.fetch_events_from_api
    events = []
    faisbook_ids = scrape_event_ids

    faisbook_ids.each do |faisbook_id|
      url = "https://graph.#{DOMAIN}/v2.5/#{faisbook_id}?access_token=221487008193174%7C239e8bd7cbb603957391246491cff75a"
      result = begin
                open(url).read
               rescue OpenURI::HTTPError
                 puts "Unable to read event_id #{faisbook_id}"
                 nil
               end

      unless result.nil?
        events << JSON.parse(result)
      end
    end

    events
  end

  def self.date_from_datetime_string(datetime_string)
    datetime_string[0..9]
  end

  def self.save_event(json_event)
    faisbook_id = json_event['id']
    new_event = find(faisbook_id: faisbook_id) || new

    new_event.faisbook_id = faisbook_id
    new_event.name = json_event['name']
    new_event.description = json_event['description']
    new_event.location = json_event['place']['name']

    json_location = json_event['place']['location']

    new_event.address = "#{json_location['street']} #{json_location['city']} #{json_location['state']}"
    new_event.start_time = json_event['start_time']
    new_event.end_time = json_event['end_time']
    new_event.date = date_from_datetime_string(json_event['end_time'])
    new_event.save unless new_event.changed_columns.empty?
  end

  def self.fetch_and_save_all
    json_events = fetch_events_from_api
    json_events.each do |json_event|
      save_event(json_event)
    end

    nil
  end

end



