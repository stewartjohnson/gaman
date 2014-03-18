module Gaman
  # Functionality for sending and receiving messages through FIBS.
  module FibsMessaging
    # Shout a message to all players who are currently logged in.
    # @return [void]
    #
    # @example
    #   fibs.shout 'This is sent to all players.'
    def shout(message)
      @connection.puts("shout #{message}")
    end

    # Tell a message to another player.
    # @return [void]
    #
    # @example
    #   fibs.tell 'someplayer', 'Keen to play a game at 10pm AEST?'
    def tell(name, message)
      @connection.puts("tell #{name} #{message}")
    end

    # Whisper a message to people watching the same game.
    # @return [void]
    # @todo check to see if we're playing or watching a game.
    #
    # @example
    #   fibs.whisper 'Hello and hope you enjoy watching this game.'
    def whisper(message)
      @connection.puts("whisper #{message}")
    end

    # Send a message to all players and watchers of the current game.
    # @return [void]
    # @todo check to see if we're playing a game.
    #
    # @example
    #   fibs.kibitz "Are you sure those dice aren't loaded?"
    def kibitz(message)
      @connection.puts("kibitz #{message}")
    end

    # Say something to your opponent during a game.
    # @return [void]
    # @todo check to see if we're playing a game.
    #
    # @example
    #   fibs.say 'Quick game is a good game!'
    def say(message)
      @connection.puts("say #{message}")
    end
  end
end
