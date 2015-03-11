class DateParser

  MONTH_NAMES = %w(january february march april may june july august september october november december)
  MONTH_ABBREVIATIONS = %w(jan feb mar apr may jun jul aug sep oct nov dec)
  PIPE = '|'
  DATE_REGEX = /(#{(MONTH_NAMES + MONTH_ABBREVIATIONS).join(PIPE)})\.? \d{1,2}/

  attr_reader :text

  def initialize(text)
    @text = text.downcase
  end

  def parse
    date_snippet = text.match(DATE_REGEX)
    time = Chronic.parse(date_snippet)

    return if time.nil?
    time.to_date.to_s[0..9]
  end
end
