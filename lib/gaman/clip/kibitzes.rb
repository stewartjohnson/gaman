module Gaman
  # @api private
  module Clip
    # Internal: Parses a FIBS Kibitzes CLIP message, which indicates that
    # someone has said something to all players and watchers of a particular
    # game. Message is in the format:
    #
    #  name message
    #
    #  name:    name of the player that kibitzed.
    #  message: kibitz sent by the user.
    class Kibitzes
      def initialize(text)
        @name, @message = text.split(' ', 2)
      end

      def update(state)
        state.message_received(:kibitz, @name, @message)
      end
    end
  end
end
