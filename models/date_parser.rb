class DateParser

  MONTH_NAMES = %w(january february march april may june july august september october november december)
  MONTH_ABBREVIATIONS = %w(jan feb mar apr may jun jul aug sep oct nov dec)
  PIPE = '|'
  MONTH_OPTIONS = (MONTH_NAMES + MONTH_ABBREVIATIONS).join(PIPE)

  # Note the d in this should not be interpreted by ruby
  ONE_OR_TWO_DIGITS = '\d{1,2}'

  OPTIONAL_SPACES = ' *'

  OPTIONAL_PERIOD = '\.?'

  # Negative lookahead so 'March 2014' is not parsed as '2014-20'
  NOT_YEAR = '(?!\d)'

  # The word 'wrote' with a colon after it generally the preamble to a forwarded mail, not an event date
  NOT_A_FORWARD_INTRO = '(?!.{0,75}wrote:)'

  DATE_REGEX = /(#{MONTH_OPTIONS})#{OPTIONAL_PERIOD}#{OPTIONAL_SPACES}#{ONE_OR_TWO_DIGITS}#{NOT_YEAR}#{NOT_A_FORWARD_INTRO}/

  attr_reader :text

  def initialize(text)
    @text = text.downcase
  end

  def parse
    date_snippet = text.match(DATE_REGEX).to_s

    # Replace periods found in date snippet with spaces because Chronic does not understand 'march.2'
    date_snippet.gsub!('.', ' ')

    time = Chronic.parse(date_snippet)

    return if time.nil?
    time.to_date.to_s[0..9]
  end
end
