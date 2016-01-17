require 'active_support/time'

module Util

  # Most mobile browsers have both "safari" and "gecko" in the user-agent
  # Browsers and bots have "mozilla", so that is not used in browser regex
  IS_BROWSER_REGEX = /(opera|aol|msie|firefox|chrome|konqueror|safari|netscape|navigator|mosaic|lynx|amaya|omniweb|avant|camino|flock|seamonkey|gecko|iphone|android)/i

  class << self
    def hash_has_nonzero_value(hash)
      hash.each_pair.any?{|name, value| value > 0}
    end

    def current_date_in_portland
      Time.zone = 'Pacific Time (US & Canada)'
      Time.zone.now.to_date
    end

    def sha1_match?(text, sha1)
      return false if (text.nil? || sha1.nil?)
      sha1(text) == sha1
    end

    def sha1(text)
      raise ArgumentError, 'text must not be nil' if text.nil?
      Digest::SHA1.hexdigest(text)
    end

    def range_of_date_strings(num_days, offset=0)
      start_date = Util.current_date_in_portland + offset
      dates = (start_date..start_date + num_days - 1).to_a
      dates.map(&:to_s)
    end

    def by_date_empty(num_days, offset)
      # this is the version that gets sent to bots
      return {} if num_days == 0
      output = {}

      range_of_date_strings(num_days, offset).each do |date_string|
        output[date_string] = []
      end

      output
    end

    def by_date(klass, num_days, offset)
      return {} if num_days == 0
      output = {}
      start_date = current_date_in_portland + offset
      end_date = start_date + num_days - 1

      things = klass.visible.where(klass.date_column => start_date .. end_date).order(*klass.order_columns).all

      range_of_date_strings(num_days, offset).each do |date_string|
        output[date_string] = []
        # The #try in this case is for when things is empty
        while date_string == things.first.try(klass.date_column)
          output[date_string] << things.shift
        end
      end

      output
    end

    def is_browser?(user_agent)
      return false if user_agent.nil?
      !!user_agent.match(IS_BROWSER_REGEX)
    end

  end

end
