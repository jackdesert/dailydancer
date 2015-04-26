class Ledger

  # Note the abbreviation 'ip' in the class always refers to IP Address

  IP_KEY = 'IP'

  class << self
    def record_guest(ip)
      redis.sadd(date_key, ip)
    end

    def guest_list
      redis.smembers(date_key)
    end

    def party_size
      redis.scard(date_key)
    end

    def redis
      @redis ||= Redis.new
    end

    private

    def date_key
      "#{IP_KEY}-#{Util.current_date_in_portland}"
    end

  end
end
