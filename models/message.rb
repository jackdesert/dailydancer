class Message < Sequel::Model
  # SimpleLists sometimes puts the author in
  LIST_EMAIL_ADDRESS = 'list@sacredcircledance.org'
  NOBODY_EMAIL_ADDRESS = 'nobody@simplelists.com'
  UNKNOWN_AUTHOR = 'unknown'

  # These regexes would normally be in ApplicationHelper, but they are needed here
  # in order to determine duplicates
  #
  AUTHOR_IN_BODY_REGEX = /From:.*?@.*?\n\n/
  # Note the FOOTER_REGEX has the /m flag which allows it to match multiple lines
  FOOTER_REGEX = /-------------------------------------------------------------------.*/m
  FORWARDED_EMAIL_REGEX = /This email was sent from \w{1,25}\.com which does not allow forwarding of emails via email lists. Therefore the sender's email address \((.*)\) has been replaced with a dummy one. The original message follows:/

  DUPLICATE_SPLITTER_REGEX = /[,.]/

  SUBJECT_SNIP = '[SacredCircleDance] '

  RENTAL_REGEX = /(looking\s+for\s+therapy\s+space)|(\d\s+bedroom)|(one\s+bedroom)|(two\s+bedroom)|(three\s+bedroom)|(four\s+bedroom)|(to\s+rent)|(for\s+rent)|(\s+rent)|(^rent)|(sublet)|(month\s+to\s+month)/
  HOUSE_SITTER_REGEX = /house\s+sit/
  PET_SITTER_REGEX = /(dog|cat|pet)\s+sit/
  KICKSTARTER_REGEX = /kickstarter\.com/
  ASTROLOGYNOW_REGEX = /astrologynow\s+forecast/

  BATCH_SIZE = 100

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
    parse if event_date.nil?
    super
  end

  def parse
    self.event_date = parsed_date
  end

  def parse_and_save
    original_event_date = event_date
    parse

    if original_event_date != event_date
      puts "id: #{id} changed from #{original_event_date || 'nil'} to #{event_date || 'nil'}   subject: #{subject_filtered[0..40]} "
    end

    save
  end

  def parsed_date
    return nil if not_an_event?
    parsed_relative_date_from_subject_and_received_at || parsed_date_from_plain
  end

  def parsed_date_from_plain
    DateParser.new("#{subject}\n\n#{plain}", received_at).parse
  end

  def parsed_relative_date_from_subject_and_received_at
    DateParser.new(subject, received_at).parse_relative
  end

  def not_an_event?
    regexes = [RENTAL_REGEX, HOUSE_SITTER_REGEX, PET_SITTER_REGEX, KICKSTARTER_REGEX, ASTROLOGYNOW_REGEX]
    subject_and_plain = (subject + plain).downcase
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

  def author_multiple_source
    prepped = if author.include?(LIST_EMAIL_ADDRESS)
                # Here's the common pattern:
                #   author: "list@sacredcircledance.org (=?UTF-8?Q?James_Brown?=)"
                #   plain:  "From: littlenikki78@gmail.com\n\n ..."
                name = ''
                name = author.match(/Q\?(.*?)\?/).try(:captures).try(:first).to_s.gsub('_', ' ')
                email = plain.match(AUTHOR_IN_BODY_REGEX).to_s.sub('From:', '').strip
                email.empty? ? UNKNOWN_AUTHOR : "#{name} <#{email}>".strip
              elsif author.include?(NOBODY_EMAIL_ADDRESS)
                # Here's the common pattern:
                #   author: "\"Chris Browne (via sacredcircledance list)\" <nobody@simplelists.com>"
                #   plain: "This email was sent from yahoo.com which does not ..."
                name = ''
                name = author.split('(').first.strip if author.include?('(')
                email = plain.match(FORWARDED_EMAIL_REGEX).try(:captures).try(:first)
                email ? "#{name} <#{email}>".strip : UNKNOWN_AUTHOR
              else
                author
              end
    prepped.gsub('"', '').strip
  end

  def author_first_name
    first_name = author_multiple_source.split(' ').first
    first_name = first_name.gsub(/[<>]/, '') if first_name[0] == '<'
    first_name
  end

  def plain_filtered
    plain.sub(AUTHOR_IN_BODY_REGEX, '').sub(FOOTER_REGEX, '').sub(FORWARDED_EMAIL_REGEX, '')
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
    where(hidden: false).where('event_date NOT NULL')
  end

  def self.order_columns
    [:event_date, :subject]
  end

  def self.date_column
    :event_date
  end

  def self.num_hidden
    where(hidden: true).count
  end

  def self.parse_all
    max = last.id

    # Add padding in case more records are added after .parse_all is called
    max_with_padding = max + 2 * BATCH_SIZE
    counter = 0
    records_processed = 0

    while counter < max_with_padding
      # Parse each one, using a batch size of BATCH_SIZE
      # to prevent memory overload
      where("id >= #{counter} AND id <  #{counter + BATCH_SIZE}").all.each do |m|
        m.parse_and_save
        records_processed += 1
      end
      counter += BATCH_SIZE
      sleep 5
      puts counter
    end
    # Return true so presentation is clearer
    puts "#{records_processed} of #{count} records processed"
    true
  end


end
