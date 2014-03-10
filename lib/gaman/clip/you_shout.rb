module Gaman
  module Clip
    # Internal: Parses a FIBS You Shout CLIP message. This CLIP message
    # confirms that FIBS has processed your request to send a shout.  Message
    # is in the format:
    #
    #  message
    #
    #  message: shout sent by the user.
    class YouShout
      def initialize(text)
        @message = text
      end

      def update(state)
        state.message_sent(:shout, @message)
      end
    end
  end
end
