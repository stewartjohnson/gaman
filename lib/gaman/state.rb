require 'gaman/logging'
require 'gaman/messaging_state'
require 'gaman/players_state'

module Gaman
  # Internal: represents the current state of the user's interaction with
  # FIBS.
  class State
    include Logging
    include MessagingState
    include PlayersState

    def initialize(user_options, &listener)
      @user = user_options
      @players = {}
      @semaphore = Mutex.new
      @listener = listener
    end

    # Internal: notify the listener that the subjects have changed.
    def signal_change(subject, payload)
      @listener[subject, payload]
    end

    def username
      @semaphore.synchronize { @user[:username] }
    end

    def credentials
      @semaphore.synchronize { "#{@user[:username]} #{@user[:password]}" }
    end

    def motd
      @semaphore.synchronize { @motd }
    end

    def motd=(text)
      @semaphore.synchronize { @motd = text }
    end

    def update_user(user_options)
      @semaphore.synchronize { @user.merge!(user_options) }
      signal_change(:user, @user)
    end

    def user(key)
      @semaphore.synchronize { @user[key] }
    end
  end
end
