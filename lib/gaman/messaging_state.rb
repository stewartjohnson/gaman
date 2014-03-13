require 'gaman/logging'
require 'gaman/message_database'

module Gaman
  # Internal: provides methods for keeping track of FIBS messages (shouts,
  # whispers, etc). The parameter 'type' on methods in this module can have
  # one of 4 values:
  # :shout   - sent to all logged in players
  # :whisper - sent to all players watching the same game as us
  # :kibitz  - sent to all players watching or playing the game we're
  #            playing
  # :message - (captures 'say' and 'tell' commands) the user who received
  #            the message will be specified in the to parameter
  #
  # TODO: this module is making use of the @user[:username] variable which is
  # a bit of high coupling to the State class. Is there some other way of
  # getting or inferring that value?
  module MessagingState
    # Internal: holds all messages that have been sent to or received by this
    # user: shouts, whispers, the lot.
    def message_db
      @message_db ||= MessageDatabase.new
    end

    # Internal: indicates that we have sent a message of 'type'. Audience of
    # the message (:to) is based on the type.
    def message_sent(type, text, to = nil)
      msg = message_db.add(
        type: type,
        to:   to,
        from: username,
        text: text,
        time: nil
        )
      signal_change(type, msg)
    end

    # Internal: receive this to confirm a 'message' command worked
    # immediately. It doesn't tell us what message we're talking about, so
    # we'd have to look through the record of messages that were previously
    # sent to this user -- we would have to assume that the first one with no
    # confirmation (not delivered or saved) is to be updated by this request.
    def message_delivered(name)
      fail NotImplementedError
    end

    # Internal: receive this to confirm a 'message' command spooled the
    # message for later. doesn't tell us what message we're talking about, so
    # we'd have to look through the record of messages that were previously
    # sent to this user -- we would have to assume that the first one with no
    # confirmation (not delivered or saved) is to be updated by this request.
    def message_saved(name)
      fail NotImplementedError
    end

    # Internal: indicates a message was received by someone who used the 'say'
    # or 'tell' command to us. Note that the message may have been sent a
    # while ago and only just delivered to us (specified by the time
    # parameter).
    def message_received(type, from, text, time = nil)
      msg = message_db.add(
        type: type,
        to:   type == :message ? username : nil,
        from: from,
        text: text,
        time: time
        )
      signal_change(type, msg)
    end

    def messages(options)
      message_db.list(options)
    end
  end
end
