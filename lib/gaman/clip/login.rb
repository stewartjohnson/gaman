module Gaman
  module Clip
    # Internal: Parses a FIBS Login CLIP message. Message is in the format:
    #
    #  name message
    #
    #  name:    name of the player that logged in.
    #  message: message that a normal user would see.
    class Login
      def initialize(text)
        @name, _ = text.split(' ', 2)
      end

      def update(state)
        state.login(@name)
      end
    end
  end
end
