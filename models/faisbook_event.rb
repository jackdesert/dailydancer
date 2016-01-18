require 'open-uri'
require 'mechanize'
require 'pry'

class FaisbookEvent < Sequel::Model

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
    agent.get('http://m.facebook.com/')
  end

  def self.dance_page
    # Using faisbook's mobile-optimized site because it does not depend on Javascript!
    dance_page = agent.get('http://m.facebook.com/groups/sacredcircledance')
  end

  def self.scrape_event_ids
    logout
    # Note that only string values are recognized in params
    form = login_page.forms.first
    email_field = form.field_with(name: 'email')
    email_field.value = 'facebook@sunni.ru'
    password_field = form.field_with(name: 'pass')
    password_field.value = 's0prano'

    form.submit
    dance_page = agent.get('http://m.facebook.com/groups/sacredcircledance')
    links = dance_page.links_with(:href => %r{/events/\d+})
    event_ids = links.map do |link|
      link.uri.to_s.match(/\/events\/(\d+)/)
      $1
    end

    event_ids.uniq
  end

  def self.fetch_events_from_api
    events = []
    event_ids = scrape_event_ids

    event_ids.each do |event_id|
      url = "https://graph.facebook.com/v2.5/#{event_id}?access_token=221487008193174%7C239e8bd7cbb603957391246491cff75a"
      result = begin
                open(url).read
               rescue OpenURI::HTTPError
                 puts "Unable to read event_id #{event_id}"
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

  def self.fetch_and_save
  end

end



