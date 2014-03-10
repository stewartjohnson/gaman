module Gaman
  module Clip
    # Internal: Parses a FIBS Whispers CLIP message, which indicates that
    # another person who is watching the same game as you said something for
    # only the people watching. Message is in the format:
    #
    #  name message
    #
    #  name:    name of the player that whispered.
    #  message: whisper sent by the user.
    class Whispers
      def initialize(text)
        @name, @message = text.split(' ', 2)
      end

      def update(state)
        state.message_received(:whisper, @name, @message)
      end
    end
  end
end
