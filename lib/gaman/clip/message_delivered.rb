module Gaman
  module Clip
    # Internal: Parses a FIBS Message Delivered CLIP message. Message is in
    # the format:
    #
    #  name
    #
    #  name:    name of the player to whom the message was delivered.
    class MessageDelivered
      def initialize(text)
        @name = text.chomp
      end

      def update(state)
        state.message_delivered(@name)
      end
    end
  end
end
