module Gaman
  module Clip
    # Internal: Parses a FIBS You Kibitz CLIP message. This CLIP message
    # confirms that FIBS has processed your request to send a kibitz.  Message
    # is in the format:
    #
    #  message
    #
    #  message: kibitz sent by the user.
    class YouKibitz
      def initialize(text)
        @message = text
      end

      def update(state)
        state.message_sent(:kibitz, @message)
      end
    end
  end
end
