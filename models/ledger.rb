class Ledger

  # Note the abbreviation 'ip' in the class always refers to IP Address

  IP_KEY = 'IP'

  class << self
    def record_guest(ip)
      begin
        redis.sadd(date_key, ip)
      rescue Redis::CannotConnectError
        # This is rescued so redis cannot bring down the site
      end
    end

    def guest_list
      redis.smembers(date_key)
    end

    def party_size
      begin
        redis.scard(date_key)
      rescue Redis::CannotConnectError
        # This is rescued so redis cannot bring down the site
      end
    end

    def redis
      @redis ||= Redis.new
    end

    def available?
      # This method is used as a health check
      begin
        redis.ping
        true
      rescue Redis::CannotConnectError
        false
      end
    end

    private

    def date_key
      "#{IP_KEY}-#{Util.current_date_in_portland}"
    end

  end
end
