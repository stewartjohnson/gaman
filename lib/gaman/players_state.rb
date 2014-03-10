module Gaman
  # Internal: represents the current state of the the players who are logged
  # in to FIBS.
  module PlayersState
    def update_player(player_login, player_options)
      @semaphore.synchronize do
        @players[player_login] = {} unless @players.key?(player_login)
        @players[player_login].merge! player_options
        @players[player_login][:online] = true
      end
      signal_change(:players)
    end

    def login(player_login)
      @semaphore.synchronize do
        @players[player_login] = {} unless @players.key?(player_login)
        @players[player_login][:online] = true
      end
    end

    def logout(player_login)
      @semaphore.synchronize do
        @players[player_login] = {} unless @players.key?(player_login)
        @players[player_login][:online] = false
      end
    end

    def players
      @semaphore.synchronize { @players }
    end

    def active_players
      @semaphore.synchronize do
        @players.reject { |name, attrs| !attrs[:online] }
      end
    end
  end
end
