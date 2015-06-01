class DateParser

  MONTH_NAMES = %w(january february march april may june july august september october november december)
  MONTH_ABBREVIATIONS = %w(jan feb mar apr may jun jul aug sep oct nov dec)
  PIPE = '|'
  MONTH_OPTIONS = (MONTH_NAMES + MONTH_ABBREVIATIONS).join(PIPE)

  # Note the d in this should not be interpreted by ruby
  ONE_OR_TWO_DIGITS = '\d{1,2}'

  OPTIONAL_SPACES = ' *'
  ONE_OR_MORE_SPACES = ' +'

  OPTIONAL_PERIOD = '\.?'

  # Negative lookahead so 'March 2014' is not parsed as '2014-20'
  NOT_YEAR = '(?!\d)'

  # The word 'wrote' with a colon after it generally the preamble to a forwarded mail, not an event date
  NOT_A_FORWARD_INTRO = '(?!.{0,75}wrote:)'

  END_OF_PERIOD_PHRASES = ['through', 'starting', 'ending', 'as soon as', 'as early as', 'as late as', 'no later than', 'by', 'until', 'before', 'due']

  NEGATIVE_LOOKBEHINDS = END_OF_PERIOD_PHRASES.map { |phrase| "(?<!#{phrase} )" }.join


  DATE_REGEX = /#{NEGATIVE_LOOKBEHINDS}(#{MONTH_OPTIONS})#{OPTIONAL_PERIOD}#{OPTIONAL_SPACES}#{ONE_OR_TWO_DIGITS}#{NOT_YEAR}#{NOT_A_FORWARD_INTRO}/


  DAYS_OF_WEEK = %w(sunday monday tuesday wednesday thursday friday saturday)
  DAYS_OF_WEEK_OPTIONS = DAYS_OF_WEEK.join(PIPE)
  RELATIVE_DATE_REGEX = /this#{ONE_OR_MORE_SPACES}(coming#{ONE_OR_MORE_SPACES})?(#{DAYS_OF_WEEK_OPTIONS})/
  DAY_OF_WEEK_REGEX = /(#{DAYS_OF_WEEK_OPTIONS})/

  attr_reader :text, :now

  def initialize(text, now)
    @text = text.downcase
    # now is the time from which chronic sees the world
    @now = now
  end

  def parse
    # This method looks for things like "March 15"
    date_snippet = text.match(DATE_REGEX).to_s

    # Replace periods found in date snippet with spaces because Chronic does not understand 'march.2'
    date_snippet.gsub!('.', ' ')

    time = Chronic.parse(date_snippet, chronic_options)

    return if time.nil?
    time.to_date.to_s[0..9]
  end

  def parse_relative
    # This method looks for things like "This Friday"
    date_snippet = text.match(RELATIVE_DATE_REGEX).to_s
    return if date_snippet.empty?

    day_of_week_in_text = date_snippet.match(DAY_OF_WEEK_REGEX).to_s

    return if now.to_date.strftime('%A').downcase == day_of_week_in_text

    # First date to try is the day after received
    date = now.to_date + 1
    6.times do
      attempted_day_of_week = date.strftime('%A').downcase
      return date.to_s if attempted_day_of_week == day_of_week_in_text

      date += 1
    end

    nil
  end

  def chronic_options
    { now: now }
  end

end
