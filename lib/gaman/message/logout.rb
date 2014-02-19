module Gaman
  module Message
    # Internal: Parses a FIBS Logout message. Message is in the format:
    #  name message
    #  name:    name of the player that logged out.
    #  message: message that a normal user would see.
    class Logout
      def initialize(text)
        @name, _ = text.split(' ', 2)
      end

      def update(state)
        state.logout(@name)
      end
    end
  end
end
