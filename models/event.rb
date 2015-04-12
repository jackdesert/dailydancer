require 'open-uri' # loads the :open method

class Event < Sequel::Model

  class ParseException < Exception;end

  EQUALITY_FIELDS = [:day_of_week, :time, :name, :url, :hostess,  :location, :location_url, :occurs_on]
  ALL_WEEKS = 'all'

  SAVED_WEB_PAGE = 'data/pdxecstaticdance.com.html'
  SAVED_WEB_PAGE_TEMP = "#{SAVED_WEB_PAGE}_TEMP"
  ERROR_FILE_FROM_THREAD = 'error_from_thread.txt'
  EVENT_LOAD_LOG = 'log/events_loaded.log'
  MIN_EXPECTED_SIZE = 10_000
  URL_BASE = 'http://pdxecstaticdance.com/'

  ONE_OR_MORE_WHITESPACES_REGEX = /\s+/
  SPACE = ' '
  COMMA = ','

  KLASS_LAST_LOADED_SEMAPHORE = Mutex.new
  CURRENTLY_LOADING_SEMAPHORE = Mutex.new

  class << self
    attr_accessor :klass_day_of_week
  end

  # These now come from Sequel, as they are defined in the database
  # attr_accessor :day_of_week, :time, :name, :url, :hostess,  :location, :location_url
  #


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

    self.occurs_on = if occurrences.empty?
      ALL_WEEKS
    else
      occurrences.join(COMMA)
    end

  end

  def name_formatted
    # This makes things sort correctly because
    # some names have newlines in them instead of spaces
    name.gsub(ONE_OR_MORE_WHITESPACES_REGEX, SPACE)
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

  def location_formatted
    return 'SomaSpace' if location.downcase == 'somaspace'
    location.titleize
  end

  def address
    match = location_url.match(/\?q=([^&]+)/)
    return '' unless match
    match[1].gsub('+', SPACE)
  end

  # Redefine the equality operator to only check particular fields
  def ==(other_event)
    EQUALITY_FIELDS.each do |field|
      return false unless send(field) == other_event.send(field)
    end

    true
  end

  def self.by_date(num_days, offset)
    output = {}
    Util.range_of_date_strings(num_days, offset).each do |date_string|
      output[date_string] = for_date_string(date_string)
    end

    output
  end

  def self.for_date_string(date_string)
    date = Date.parse(date_string)
    occurrence = which_occurrence(date)

    day_of_week = date.strftime('%A').downcase
    events = where(day_of_week: day_of_week).all.sort_by(&:name_formatted)

    events.select do |event|
      event.occurs_on == ALL_WEEKS || event.occurs_on.split(COMMA).map(&:to_i).include?(occurrence)
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

    unless success == true
      log("02 not loaded because return value from curl is false")
      return false
    end

    if File.stat(SAVED_WEB_PAGE_TEMP).size > MIN_EXPECTED_SIZE
      # Only copy if curl successfully grabbed a large enough file to appear reasonable
      FileUtils.cp(SAVED_WEB_PAGE_TEMP, SAVED_WEB_PAGE)
      true
    else
      log("03 not loaded because results from curl too small")
      false
    end
  end

  def self.load_in_thread_if_its_been_a_while

    unless been_a_while?
      log("00 not loaded because last loaded at #{klass_last_loaded_at}")
      return false
    end

    if currently_loading?
      log("01 not loaded because currently_loading")
      return false
    end

    self.currently_loading = true

    # Set last_loaded_at before thread starts instead of when thread finishes so that
    # with high traffic, still only one thread gets loaded
    self.klass_last_loaded_at = Time.now

    Thread.new do

      # This sleep is to allow the server request to be serviced before loading,
      # because during the load there is a short window where each event will
      # show up twice
      sleep 2

      begin
        # calling explicitly on self because load means other things too
        self.load

      rescue Exception => e
        data = "#{e.message}\n#{e.backtrace.join("\n")}"

        log("09 not loaded because exception raised: #{data}")
      ensure
        self.currently_loading = false
      end
    end
  end

  def self.been_a_while?
    return true if klass_last_loaded_at.nil?
    (Time.now - klass_last_loaded_at).abs > 1.hour
  end

  def self.load
    previous_last_id = last.try(:id).to_i

    unless fetch_events
      log("04 not loaded because fetch_events failed")
      return false
    end

    # Load from file. This will most often be from last time
    file = File.open(SAVED_WEB_PAGE)
    doc = Nokogiri::HTML(file)

    rows = doc.css('table').first.css('tr')

    # Remove the header row
    rows.shift

    # create new events and delete old ones within a transaction
    # so we always end up with correct number of events
    DB.transaction do
      log("05 about to create new events. There are now #{Event.count} events. Last id is #{Event.last.try(:id)}")
      new_events = rows.map do |row|
        new_event_from_row(row)
      end

      # Note `new_events` will have some nil values because new_event_from_row
      # returns nil when the row does not represent an event
      new_events.compact!

      if at_least_one_event_changed?(new_events)
        new_events.each {|e| e.save}
        log("06 new events created. There are now #{Event.count} events. Last id is #{Event.last.try(:id)}")

        delete_all_with_id_less_than(previous_last_id)
        log("07 old events deleted. There are now #{Event.count} events. Last id is #{Event.last.try(:id)}")
      else
        log("07 events not loaded because new events match what is in database. There are now #{Event.count} events. Last id is #{Event.last.try(:id)}")
      end

    end

    log("08 load completed. There are now #{Event.count} events. Last id is #{Event.last.try(:id)}")

    true
  end

  def self.delete_all_with_id_less_than(previous_last_id)
    where("id <= #{previous_last_id}").each(&:delete)
  end

  def self.new_event_from_row(row)
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

    event
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

  def self.at_least_one_event_changed?(new_events)
    # Note this calls our customized '==' operator that
    # only compares certain fields
    all != new_events
  end

  def self.log(text)
    File.open(EVENT_LOAD_LOG, 'a') { |file| file.write("#{Time.now} #{text}\n") }
  end

  def self.klass_last_loaded_at
    KLASS_LAST_LOADED_SEMAPHORE.synchronize do
      @klass_last_loaded_at
    end
  end

  def self.klass_last_loaded_at=(time)
    KLASS_LAST_LOADED_SEMAPHORE.synchronize do
      @klass_last_loaded_at = time
    end
  end

  def self.currently_loading?
    CURRENTLY_LOADING_SEMAPHORE.synchronize do
      @currently_loading
    end
  end

  def self.currently_loading=(state)
    CURRENTLY_LOADING_SEMAPHORE.synchronize do
      @currently_loading = state
    end
  end

end
