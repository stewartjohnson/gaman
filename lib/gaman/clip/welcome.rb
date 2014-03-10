require 'date'

module Gaman
  module Clip
    # Internal: Parses a FIBS Welcome CLIP message. Message is in the format:
    #
    #     myself 1041253132 192.168.1.308
    #
    # myself        - username (not required)
    # 1041253132    - last login (seconds since epoch UTC)
    # 192.168.1.308 - last ip address
    class Welcome
      def initialize(text)
        _, secs_since_epoch_utc, last_ip = text.split(' ', 3)
        @last_login = Time.at(secs_since_epoch_utc.to_i).utc.to_datetime
        @last_ip = last_ip
      end

      def update(state)
        state.update_user(last_login: @last_login, last_ip: @last_ip)
      end
    end
  end
end
