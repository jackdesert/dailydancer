module ApplicationHelper
  # Note the FOOTER_REGEX has the /m flag which allows it to match multiple lines
  FOOTER_REGEX = /-------------------------------------------------------------------.*/m

  FORWARDED_EMAIL_REGEX = /This email was sent from \w{1,25}\.com which does not allow forwarding of emails via email lists. Therefore the sender's email address \(.*\) has been replaced with a dummy one. The original message follows:/

  LINE_FEED = "\n"

  HTTP_OR_HTTPS_REGEX = /http(s)?/
  ENDS_WITH_PERIOD_REGEX = /\.\z/

  def display_date(date)
    Chronic.parse(date).strftime('%A, %b %d')
  end

  def details_as_array(message)
    # This is returned as an array so haml can be used to do the line breaks
    raise ArgumentError, 'Expected a Message' unless message.is_a?(Message)
    text = message.plain_filtered
    text = insert_hyperlinks(text)
    text.split(LINE_FEED)
  end

  def insert_hyperlinks(text)
    hyperlinks = URI.extract(text, HTTP_OR_HTTPS_REGEX)
    hyperlinks.each do |hyperlink|
      hyperlink.sub!(ENDS_WITH_PERIOD_REGEX, '')
    end

    output = ''

    hyperlinks.each do |hyperlink|
      # Split into at most two pieces
      text_array = text.split(hyperlink, 2)

      # Put the first part in the output so we do not search it for any more links
      # since some links are subset of others
      output += text_array.first
      output += "<a href='#{hyperlink}' target='_blank'>#{hyperlink}</a>"

      # Use the last part going forward
      text = text_array.last
    end

    # Add remaining text to output
    output += text
    output
  end

  def mailto(last_word='')
    "mailto:Jack%20Desert<jackdesert@gmail.com>?subject=Daily%20Dancer%20#{last_word}"
  end

  def deduplicate(original_messages)
    # This method checks the group of original_messages passed in and if any of
    # them are duplicates, includes only the one with the latest :received_at
    output = []

    while original_messages.length > 0

      message = original_messages.shift
      duplicates = []

      original_messages.each do |other_message|
        duplicates << other_message if message.duplicate_of?(other_message)
      end

      # Delete duplicates from original_messages
      # This is done in a separate step so the array will not change size
      # during the 'each' block above
      duplicates.each do |duplicate|
        original_messages.delete(duplicate)
      end

      message_with_duplicates = duplicates << message

      # Now the message and its duplicates are all in 'duplicates'
      # so we pick the one with the latest received_at

      output << message_with_duplicates.max_by(&:received_at)
    end

    output
  end
end

