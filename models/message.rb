class Message < Sequel::Model
  # These regexes would normally be in ApplicationHelper, but they are needed here
  # in order to determine duplicates
  #
  # Note the FOOTER_REGEX has the /m flag which allows it to match multiple lines
  FOOTER_REGEX = /-------------------------------------------------------------------.*/m
  FORWARDED_EMAIL_REGEX = /This email was sent from \w{1,25}\.com which does not allow forwarding of emails via email lists. Therefore the sender's email address \(.*\) has been replaced with a dummy one. The original message follows:/

  DUPLICATE_SPLITTER_REGEX = /[,.]/

  SUBJECT_SNIP = '[SacredCircleDance] '

  RENTAL_REGEX = /(to\s+rent)|(for\s+rent)|(sublet)|(month\s+to\s+month)/
  HOUSE_SITTER_REGEX = /house\s+sit/
  PET_SITTER_REGEX = /(dog|cat|pet)\s+sit/
  KICKSTARTER_REGEX = /kickstarter\.com/

  plugin :validation_helpers

  attr_accessor :marked_as_duplicate

  def validate
    super
    # Note there is no validation on received_at because it is set
    # in before_create (which happens after validation)
    #
    # Note there is no validation on html or plain, since one of them may be blank
    # TODO require at least one of them to be present
    validates_presence :author
    validates_presence :subject
    validates_presence :plain
  end

  def before_create
    self.received_at ||= DateTime.now
    super
  end

  def parsed_date
    return nil if not_an_event?
    @parsed_date ||= parsed_relative_date_from_subject_and_received_at || parsed_date_from_plain
  end

  def parsed_date_from_plain
    DateParser.new(plain).parse
  end

  def parsed_relative_date_from_subject_and_received_at
    DateParser.new(subject).parse_relative(received_at)
  end

  def not_an_event?
    regexes = [RENTAL_REGEX, HOUSE_SITTER_REGEX, PET_SITTER_REGEX, KICKSTARTER_REGEX]
    subject_and_plain = subject + plain
    regexes.any?{|f| subject_and_plain.match(f)}
  end

  def duplicate_of?(other_message)
    # Note that this method is used to de-duplicate emails
    # And is intended to be used on events that have the same parsed_date

    threshold = if author == other_message.author
                  1.0
                else
                  1.2
                end
    subject_duplication_score(other_message) + plain_duplication_score(other_message) > threshold
  end

  def subject_duplication_score(other_message)
    self_subject_array                = subject_filtered.split.reject{|f| f.length < 3}
    other_subject_array = other_message.subject_filtered.split.reject{|f| f.length < 3}
    duplication_score(self_subject_array, other_subject_array)
  end

  def plain_duplication_score(other_message)
    self_plain_array                = plain_filtered.split(DUPLICATE_SPLITTER_REGEX)
    other_plain_array = other_message.plain_filtered.split(DUPLICATE_SPLITTER_REGEX)
    duplication_score(self_plain_array, other_plain_array)
  end

  def duplication_score(array_1, array_2)
    [array_1, array_2].each do |array|
      array.map! {|f| f.downcase.gsub(/\s/, '') }
    end

    total_number_of_lines = array_1.count + array_2.count

    # Convert at least one of these to a float so the division below will be floating point
    left_diff = (array_1 - array_2).count.to_f
    right_diff = (array_2 - array_1).count

    1.0 - ((left_diff + right_diff) / total_number_of_lines)
  end

  def mark_as_duplicate
    self.marked_as_duplicate = true
  end

  def marked_as_duplicate?
    marked_as_duplicate
  end

  def plain_filtered
    plain.sub(FOOTER_REGEX, '').sub(FORWARDED_EMAIL_REGEX, '')
  end

  def subject_filtered
    subject.sub(SUBJECT_SNIP, '')
  end

  def hide(reason)
    self.hidden = true
    self.hide_reason = reason
    save
    puts "This subject now hidden: \"#{subject}\""
  end

  def self.visible
    where(hidden: false)
  end

  def self.future
    messages = visible.all.select do |message|
      message.parsed_date && message.parsed_date >= Util.current_date_in_portland.to_s
    end
  end

  def self.by_date(num_days)
    return {} if num_days == 0
    output = {}
    messages = future.sort_by{|m| "#{m.parsed_date} #{m.subject}"}

    range_of_date_strings(num_days).each do |date_string|
      output[date_string] = []
      while date_string == messages.first.try(:parsed_date)
        output[date_string] << messages.shift
      end
    end

    output
  end

  def self.range_of_date_strings(num_days)
    today = Util.current_date_in_portland
    dates = (today..today + num_days - 1).to_a
    dates.map(&:to_s)
  end

end
