module Gaman
  module Message
    # Internal: Parses a FIBS MOTD message.
    class Motd
      def initialize(text)
        # TODO: get rid of the ASCII border around the message. (maybe?)
        @text = text
      end

      def update(state)
        state.motd = @text
      end
    end
  end
end
