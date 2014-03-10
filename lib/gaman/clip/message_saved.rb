module Gaman
  module Clip
    # Internal: Parses a FIBS Message Saved CLIP message. Message is in
    # the format:
    #
    #  name
    #
    #  name:    name of the player to whom the message was saved.
    class MessageSaved
      def initialize(text)
        @name = text.chomp
      end

      def update(state)
        state.message_saved(@name)
      end
    end
  end
end
