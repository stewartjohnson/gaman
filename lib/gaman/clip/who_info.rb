require 'date'

module Gaman
  module Clip
    # Internal: Parses a FIBS WhoInfo CLIP message. Message is in the format:
    #
    #   name opponent watching ready away rating experience idle login \
    #     hostname client email
    #
    # name:       The login name for the user this line is referring to.
    # opponent:   The login name of the person the user is currently playing
    #             against, or a hyphen if they are not playing anyone.
    # watching:   The login name of the person the user is currently watching,
    #             or a hyphen if they are not watching anyone.
    # ready:      1 if the user is ready to start playing, 0 if not. Note that
    #             the ready status can be set to 1 even while the user is
    #             playing a game and thus, technically unavailable.
    # away:       1 for yes, 0 for no.
    # rating:     The user's rating as a number with two decimal places.
    # experience: The user's experience.
    # idle:       The number of seconds the user has been idle.
    # login:      The time the user logged in as the number of seconds since
    #             midnight, January 1, 1970 UTC.
    # hostname:   The host name or IP address the user is logged in from. Note
    #             that the host name can change from an IP address to a host
    #             name due to the way FIBS host name resolving works.
    # client:     The client the user is using (see login) or a hyphen if not
    #             specified.
    # email:      The user's email address, or a hyphen if not specified.
    class WhoInfo
      def initialize(text)
        name, opponent, watching, ready, away, rating, experience, idle,
          login, hostname, client, email = text.split(' ', 12)
        @name       = name
        @opponent   = (opponent == '-' ? nil : opponent)
        @watching   = (watching == '-' ? nil : watching)
        @ready      = (ready == '1')
        @away       = (away == '1')
        @rating     = rating.to_f
        @experience = experience.to_i
        @idle       = idle.to_i
        @last_login = Time.at(login.to_i).utc.to_datetime
        @hostname   = hostname
        @client     = (client == '-' ? nil : client)
        @email      = (email == '-' ? nil : email)
      end

      def update(state)
        state.update_player(
          @name, opponent: @opponent,
                 watching: @watching,
                 ready: @ready,
                 away: @away,
                 rating: @rating,
                 experience: @experience,
                 idle: @idle,
                 last_login: @last_login,
                 hostname: @hostname,
                 client: @client,
                 email: @email
          )
      end
    end
  end
end
