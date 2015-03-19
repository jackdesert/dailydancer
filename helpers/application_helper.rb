module ApplicationHelper
  # Note the FOOTER_REGEX has the /m flag which allows it to match multiple lines
  FOOTER_REGEX = /-------------------------------------------------------------------.*/m

  FORWARDED_EMAIL_REGEX = /This email was sent from \w{1,25}\.com which does not allow forwarding of emails via email lists. Therefore the sender's email address \(.*\) has been replaced with a dummy one. The original message follows:/

    SUBJECT_SNIP = '[SacredCircleDance] '

  LINE_FEED = "\n"

  HTTP_OR_HTTPS_REGEX = /http(s)?/
    ENDS_WITH_PERIOD_REGEX = /\.\z/

    def display_date(date)
      Chronic.parse(date).strftime('%A, %b %d')
    end

  def details_as_array(message)
    # This is returned as an array so haml can be used to do the line breaks
    raise ArgumentError, 'Expected a Message' unless message.is_a?(Message)
    text = message.plain
    text.sub!(FOOTER_REGEX, '')
    text.sub!(FORWARDED_EMAIL_REGEX, '')
    text = insert_hyperlinks(text)
    text.split(LINE_FEED)
  end

  def formatted_subject(message)
    raise ArgumentError, 'Expected a Message' unless message.is_a?(Message)
    text = message.subject
    text.sub(SUBJECT_SNIP, '')
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
end

