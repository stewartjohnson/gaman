module Gaman
  module Clip
    # Internal: Parses a FIBS MOTD CLIP message.
    #
    # The CLIP format is actually two commands (#3 and #4) with the MOTD text
    # in between. However the ClipFactory handles those and creates this
    # object with only the MOTD text.
    class Motd
      def initialize(text)
        # TODO: get rid of the ASCII border around the message. (maybe?)
        @text = text
      end

      def update(state)
        state.motd = @text
      end
    end
  end
end
