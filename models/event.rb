class Event < Sequel::Model

  class ParseException < Exception;end

  # These now come from Sequel, as they are defined in the database
  # attr_accessor :day_of_week, :time, :name, :url, :hostess,  :location, :location_url

  def before_create
    self.scraped_at ||= DateTime.now
    super
  end

  class << self
    attr_accessor :klass_day_of_week
  end

  def self.load
    puts 'Hiiiiiiiiiiiiiiiiiiiiiiiiiiiiii'
    file = File.open('file.txt')
    doc = Nokogiri::HTML(file)
    rows = doc.css('table').first.css('tr')

    # Remove the header row
    rows.shift
    rows.each do |row|
      create_event_from_row(row)
    end
  end

  def self.capture_preexisting_and_delete_them_after_new_ones_created
    # TODO
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
    event.day_of_week = klass_day_of_week
    event.time = text_from_cell(cells.shift)

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


end
