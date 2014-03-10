module Gaman
  module Clip
    # Internal: Parses a FIBS Says CLIP message, which indicates that another
    # player has said something to you (and only you) by either using the
    # 'say' command during a game with you, or a 'tell' command. Message is in
    # the format:
    #
    #  name message
    #
    #  name:    name of the player that sent the message.
    #  message: message sent by the user.
    class Says
      def initialize(text)
        @name, @message = text.split(' ', 2)
      end

      def update(state)
        state.message_received(:message, @name, @message)
      end
    end
  end
end
