require 'active_support/time'

module Util

  IS_BROWSER_REGEX = /(opera|aol|msie|firefox|chrome|konqueror|safari|netscape|navigator|mosaic|lynx|amaya|omniweb|avant|camino|flock|seamonkey|mozilla|gecko)/i

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

    def is_browser?(user_agent)
      return false if user_agent.nil?
      !!user_agent.match(IS_BROWSER_REGEX)
    end

  end

end
