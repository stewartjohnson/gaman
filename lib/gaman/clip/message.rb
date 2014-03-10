module Gaman
  module Clip
    # Internal: Parses a FIBS Message CLIP message. Message is in the format:
    #
    #  from time message
    #
    #  from:    name of the player that sent the message.
    #  time:    the time that the message was sent.
    #  message: message sent by the user.
    class Message
      def initialize(text)
        @from, secs_since_epoch_utc, @message = text.split(' ', 3)
        @time = Time.at(secs_since_epoch_utc.to_i).utc.to_datetime
      end

      def update(state)
        state.message_received(:message, @from, @message, @time)
      end
    end
  end
end
