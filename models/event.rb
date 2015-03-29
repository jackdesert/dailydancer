require 'open-uri' # loads the :open method

class Event < Sequel::Model

  class ParseException < Exception;end

  SAVED_WEB_PAGE = 'data/pdxecstaticdance.com.html'
  SAVED_WEB_PAGE_TEMP = "#{SAVED_WEB_PAGE}_TEMP"
  ERROR_FILE_FROM_THREAD = 'error_from_thread.txt'
  EVENT_LOAD_LOG = 'log/events_loaded.log'
  MIN_EXPECTED_SIZE = 10_000
  URL_BASE = 'http://pdxecstaticdance.com/'

  COMMA = ','

  class << self
    attr_accessor :klass_day_of_week, :klass_last_loaded_at
  end

  # These now come from Sequel, as they are defined in the database
  # attr_accessor :day_of_week, :time, :name, :url, :hostess,  :location, :location_url

  def before_create
    self.scraped_at ||= DateTime.now
    super
  end

  def set_occurrence_from_time
    occurrences = []
    occurrences << '1' if time.include?('1st')
    occurrences << '2' if time.include?('2nd')
    occurrences << '3' if time.include?('3rd')
    occurrences << '4' if time.include?('4th')
    occurrences << '5' if time.include?('5th')

    return if occurrences.empty?

    self.occurs_on = occurrences.join(COMMA)
  end

  def url_formatted
    if url.match /https?:\/\//
      url
    else
      URL_BASE + url
    end
  end

  def time_formatted
    if time.downcase.include?(day_of_week)
      time
    else
      "#{day_of_week.capitalize}s #{time}"
    end
  end

  def self.by_date(num_days)
    output = {}
    Util.range_of_date_strings(num_days).each do |date_string|
      output[date_string] = for_date_string(date_string)
    end

    output
  end

  def self.for_date_string(date_string)
    date = Date.parse(date_string)
    occurrence = which_occurrence(date)

    day_of_week = date.strftime('%A').downcase
    events = where(day_of_week: day_of_week).all

    events.select do |event|
      event.occurs_on == 'all' || event.occurs_on.split(COMMA).include?(occurrence)
    end
  end

  def self.which_occurrence(date)
    day = date.day
    which = 0

    while day > 0
      which += 1
      day   -= 7
    end

    which
  end

  def self.fetch_events
    url = 'http://pdxecstaticdance.com/'

    command = "curl #{url} > #{SAVED_WEB_PAGE_TEMP}"
    success = system(command)

    return unless success == true

    if File.stat(SAVED_WEB_PAGE_TEMP).size > MIN_EXPECTED_SIZE
      # Only copy if curl successfully grabbed a large enough file to appear reasonable
      FileUtils.cp(SAVED_WEB_PAGE_TEMP, SAVED_WEB_PAGE)
    end
  end

  def self.load_in_thread_if_its_been_a_while
    Thread.new do
      begin
        load_if_its_been_a_while

        # No file means no errors
        FileUtils.rm_f(ERROR_FILE_FROM_THREAD)
      rescue Exception => e
        data = "#{e.message}\n#{e.backtrace.join("\n")}"

        # File presence means something went wrong
        File.open(ERROR_FILE_FROM_THREAD, 'w') { |file| file.write(data) }
      end
    end
  end

  def self.load_if_its_been_a_while
    # TODO wrap this in a semaphore since multiple actors access the same class instance var

    return false if klass_last_loaded_at && klass_last_loaded_at < 1.hour.ago

    # Explicit self because 'load' has other meanings
    self.load
    self.klass_last_loaded_at = Time.now

    true
  end

  def self.load
    previous_last_id = last.try(:id).to_i

    fetch_events

    # Load from file. This will most often be from last time
    file = File.open(SAVED_WEB_PAGE)
    doc = Nokogiri::HTML(file)

    rows = doc.css('table').first.css('tr')

    # Remove the header row
    rows.shift
    rows.each do |row|
      create_event_from_row(row)
    end

    delete_all_with_id_less_than(previous_last_id)

    log_message = "events loaded at #{Time.now}\n"
    File.open(EVENT_LOAD_LOG, 'a') { |file| file.write(log_message) }
  end

  def self.delete_all_with_id_less_than(previous_last_id)
    where("id <= #{previous_last_id}").each(&:delete)
  end

  def self.create_event_from_row(row)
    cells = row.css('td')

    # If only one cell, this cell is for formatting only
    return if cells.length == 1

    if cells.length == 6
      # The extra cell is the day of the week, which has rowspan > 1
      self.klass_day_of_week = cells.shift.children.first.text.strip
      raise ParseException, "day of week not found" unless klass_day_of_week
    end

    event = new
    event.day_of_week = day_of_week_from_abbreviation(klass_day_of_week)

    time_cell = cells.shift
    event.time = text_from_cell(time_cell)
    event.set_occurrence_from_time

    name_cell  = cells.shift
    event.name = text_from_cell(name_cell)
    event.url  = url_from_cell(name_cell)

    event.hostess = text_from_cell(cells.shift)

    location_cell      = cells.shift
    event.location     = text_from_cell(location_cell)
    event.location_url = url_from_cell(location_cell)

    event.save
  end

  def self.text_from_cell(cell)
    cell.children.first.text.strip
  end

  def self.url_from_cell(cell)
    cell.css('a').first.attributes['href'].value
  end

  def self.day_of_week_from_abbreviation(abbreviation)
    key = abbreviation.downcase[0..2].to_sym
    hash  = { mon: 'monday',
              tue: 'tuesday',
              wed: 'wednesday',
              thu: 'thursday',
              fri: 'friday',
              sat: 'saturday',
              sun: 'sunday' }
    hash[key]
  end



end
