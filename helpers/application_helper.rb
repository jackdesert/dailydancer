module ApplicationHelper
  # Note the FOOTER_REGEX has the /m flag which allows it to match multiple lines
  FOOTER_REGEX = /-------------------------------------------------------------------.*/m

  SUBJECT_SNIP = '[SacredCircleDance] '

  LINE_FEED = "\n"

  def display_date(date)
    Chronic.parse(date).strftime('%A, %b %d')
  end

  def details_as_array(message)
    # This is returned as an array so haml can be used to do the line breaks
    raise ArgumentError, 'Expected a Message' unless message.is_a?(Message)
    text = message.plain
    text.sub!(FOOTER_REGEX, '')
    text.split(LINE_FEED)
  end

  def formatted_subject(message)
    raise ArgumentError, 'Expected a Message' unless message.is_a?(Message)
    text = message.subject
    text.sub(SUBJECT_SNIP, '')
  end


end
