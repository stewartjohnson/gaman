module Gaman
  module Clip
    # Internal: Parses a FIBS Shouts CLIP message, which indicates that
    # another player shouted something to everyone who is logged in to the
    # server. Message is in the format:
    #
    #  name message
    #
    #  name:    name of the player that shouted.
    #  message: shout sent by the user.
    class Shouts
      def initialize(text)
        @name, @message = text.split(' ', 2)
      end

      def update(state)
        state.message_received(:shout, @name, @message)
      end
    end
  end
end
