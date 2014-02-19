module Gaman
  module Message
    # Internal: Parses a FIBS OwnInfo message. Message is in the format:
    # myself 1 1 0 0 0 0 1 1 2396 0 1 0 1 3457.85 0 0 0 0 0 Australia/Melbourne
    #   name:       The login name you just logged in as.
    #   allowpip:   1 for yes, 0 for no.
    #   autoboard:  1 for yes, 0 for no.
    #   autodouble: 1 for yes, 0 for no.
    #   automove:   1 for yes, 0 for no.
    #   away:       1 for yes, 0 for no.
    #   bell:       1 for yes, 0 for no.
    #   crawford:   1 for yes, 0 for no.
    #   double:     1 for yes, 0 for no.
    #   experience: Your experience.
    #   greedy:     1 for yes, 0 for no.
    #   moreboards: 1 for yes, 0 for no.
    #   moves:      1 for yes, 0 for no.
    #   notify:     1 for yes, 0 for no.
    #   rating:     Your rating as a number to two decimal places.
    #   ratings:    1 for yes, 0 for no.
    #   ready:      1 for yes, 0 for no.
    #   redoubles:  0, 1, 2 ... or the string "unlimited".
    #   report:     1 for yes, 0 for no.
    #   silent:     1 for yes, 0 for no.
    #   timezone:   A string representing your timezone.
    class OwnInfo
      def initialize(text) # rubocop:disable MethodLength
        _, allowpip, autoboard, autodouble, automove, away, bell, crawford,
          double, experience, greedy, moreboards, moves, notify, rating,
          ratings, ready, redoubles, report, silent, timezone =
            text.split(' ', 21)
        @allowpip   = (allowpip == '1')
        @autoboard  = (autoboard == '1')
        @autodouble = (autodouble == '1')
        @automove   = (automove == '1')
        @away       = (away == '1')
        @bell       = (bell == '1')
        @crawford   = (crawford == '1')
        @double     = (double == '1')
        @experience = experience.to_i
        @greedy     = (greedy == '1')
        @moreboards = (moreboards == '1')
        @moves      = (moves == '1')
        @notify     = (notify == '1')
        @rating     = rating.to_f
        @ratings    = (ratings == '1')
        @ready      = (ready == '1')
        @redoubles  = (redoubles == 'unlimited' ? -1 : redoubles.to_i)
        @report     = (report == '1')
        @silent     = (silent == '1')
        @timezone   = timezone
      end

      def update(state)
        state.update_user(
          allowpip: @allowpip,
          autoboard: @autoboard,
          autodouble: @autodouble,
          automove: @automove,
          away: @away,
          bell: @bell,
          crawford: @crawford,
          double: @double,
          experience: @experience,
          greedy: @greedy,
          moreboards: @moreboards,
          moves: @moves,
          notify: @notify,
          rating: @rating,
          ratings: @ratings,
          ready: @ready,
          redoubles: @redoubles,
          report: @report,
          silent: @silent,
          timezone: @timezone
          )
      end
    end
  end
end
