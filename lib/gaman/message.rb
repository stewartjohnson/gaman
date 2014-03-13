module Gaman
  # Internal: Represents a message that has been sent to or from the user.
  class Message
    attr_reader :to, :from, :time, :type, :text

    # Internal: Creates a new record of a message that has been sent/received
    # through FIBS. Paramaters:
    #
    # to   - The name of the person to whom the message was sent. Can be nil,
    #        though the meaning of nil depends on the message type.
    # from - The name of the person who sent the message. The meaning of a nil
    #        value depends on the message type.
    # time - The time the message was sent. nil means it was sent immediately
    #        without spooling (i.e.: the recipient was logged in when it was
    #        sent).
    # type - :shout, :whisper, :kibitz or :message ('say' or 'tell')
    # text - the String text of the message.
    def initialize(options)
      @to   = options[:to]
      @from = options[:from]
      @time = options[:time]
      @type = options[:type]
      @text = options[:text]
    end
  end
end
