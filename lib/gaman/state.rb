require 'gaman/logging'

module Gaman
  # Internal: represents the current state of the user's interaction with
  # FIBS.
  class State
    include Logging

    def initialize(user_options)
      @user = user_options
      @players = {}
      @semaphore = Mutex.new
    end

    def motd
      @semaphore.synchronize { @motd }
    end

    def motd=(text)
      @semaphore.synchronize { @motd = text }
    end

    def update_user(user_options)
      @semaphore.synchronize { @user.merge!(user_options) }
    end

    def user(key)
      @semaphore.synchronize { @user[key] }
    end

    def update_player(player_login, player_options)
      @semaphore.synchronize do
        @players[player_login] = {} unless @players.key?(player_login)
        @players[player_login].merge! player_options
        @players[player_login][:online] = true
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
  end
end
