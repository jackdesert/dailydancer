module ApplicationHelper
  # Note the FOOTER_REGEX has the /m flag which allows it to match multiple lines
  FOOTER_REGEX = /-------------------------------------------------------------------.*/m

  FORWARDED_EMAIL_REGEX = /This email was sent from \w{1,25}\.com which does not allow forwarding of emails via email lists. Therefore the sender's email address \(.*\) has been replaced with a dummy one. The original message follows:/

  LINE_FEED = "\n"

  HTTP_OR_HTTPS_REGEX = /http(s)?/
  ENDS_WITH_PERIOD_REGEX = /\.\z/

  def display_date(date_string)
    Chronic.parse(date_string).strftime('%A, %b %d')
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

  def build_etag
    # Note this does not have any commas in it, because rack-cache will not
    # cache anything if there are commas
    "last_message_id:#{Message.last.try(:id)}/last_event_id:#{Event.last.try(:id)}/date:#{Util.current_date_in_portland}"
  end

  def display_status
    if Message.count == 0
      return 'No Messages found in database'
    end

    if (Message.last.received_at - Time.now).abs > 1.day
      return "Have not received new messages recently. Last message at #{Message.last.received_at}"
    end

    unless (Event.count > 10) && (Event.count < 22)
      return "Number of Events expected to be between 10 and 22, but found #{Event.count}"
    end

    time_ago_in_hours = (Message.last.received_at - Time.now).abs / 3600

    lines = ["All Systems Go",
             "#{time_ago_in_hours.round(1)} hours ago" ,
             "Message.count: #{Message.count}",
             "Event.count: #{Event.count}",
             'Most Recent Message:',
             "  received_at: #{Message.last.received_at}",
             "  subject: #{Message.last.subject_filtered}"]
    lines.join("\n")
  end

end

