module Gaman
  module Clip
    # Internal: Parses a FIBS You Whisper CLIP message. This CLIP message
    # confirms that FIBS has processed your request to send a whisper. Message
    # is in the format:
    #
    #  message
    #
    #  message: whisper sent by the user.
    class YouWhisper
      def initialize(text)
        @message = text
      end

      def update(state)
        state.message_sent(:whisper, @message)
      end
    end
  end
end
