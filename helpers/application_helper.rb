module ApplicationHelper

  PRODUCTION_SERVER_NAME = 'pdxdailydancer.com'
  LOCAL_SERVER_NAME = 'dancer-local.com:9292'

  RACK_ENV = ENV['RACK_ENV']

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
    "<a href='mailto:#{Mailer::SUPPORT_EMAIL}?subject=Daily%20Dancer%20#{last_word}'>#{Mailer::SUPPORT_EMAIL}</a>"
  end

  def build_etag
    # Note this does not have any commas in it, because rack-cache will not
    # cache anything if there are commas
    "last_message_id:#{Message.last.try(:id)}/num_hidden_events:#{Message.num_hidden}/last_event_id:#{Event.last.try(:id)}/date:#{Util.current_date_in_portland}"
  end

  def system_errors
    errors = []

    if Message.count == 0
      errors << 'No Messages found in database'
    elsif (Message.last.received_at - Time.now).abs > 1.day
      errors << "Have not received new messages recently. Last message at #{Message.last.received_at}"
    end

    unless (Event.count > 10) && (Event.count < 22)
      errors << "Number of Events expected to be between 10 and 22, but found #{Event.count}"
    end

    unless (Message.count > 400)
      errors << "Number of Messages expected to be above 400, but found #{Message.count}"
    end

    unless Ledger.available?
      errors << 'Visitor tracking system is down'
    end

    errors
  end

  def last_ingestion_in_hours
    if Message.count == 0
      nil
    else
      (Message.last.try(:received_at) - Time.now).abs / 3600
    end
  end

  def server_name
    if RACK_ENV == 'production'
      PRODUCTION_SERVER_NAME
    else
      LOCAL_SERVER_NAME
    end
  end

  def root_url
    "http://#{server_name}"
  end

  def status_url
    "http://status.#{server_name}"
  end

  def faq_url
    "http://#{server_name}/faq"
  end

end

