module Gaman
  module Clip
    # Internal: Parses a FIBS You Say CLIP message. This CLIP message confirms
    # that FIBS has processed your request to send a 'say' or 'tell'.  Message
    # is in the format:
    #
    #  name message
    #
    #  name:    name of the player that the message was sent to.
    #  message: message sent by the user.
    class YouSay
      def initialize(text)
        @name, @message = text.split(' ', 2)
      end

      def update(state)
        state.message_sent(:message, @message, @name)
      end
    end
  end
end
