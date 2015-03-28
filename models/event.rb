class Event < Sequel::Model

  class ParseException < Exception;end

  attr_accessor :day_of_week, :time, :name, :location, :location_url, :url, :contact_email, :hostess

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

  def self.create_event_from_row(row)
    cells = row.css('td')
    if cells.length == 6
      self.klass_day_of_week = cells.shift.children.try(:first).try(:text).try(:strip)
      raise ParseException, "day of week not found" unless klass_day_of_week
    end

    event = new
    event.day_of_week = klass_day_of_week
    event.time = text_from_cell(cells.shift)

    name_cell = cells.shift
    event.name = text_from_cell(name_cell)
    event.url = url_from_cell(name_cell)

    binding.pry
    binding.pry
    a = 5
  end

  def self.text_from_cell(cell)
    cell.children.first.text.strip
  end

  def self.url_from_cell(cell)
    cell.css('a').first.attributes['href'].value
  end


end
