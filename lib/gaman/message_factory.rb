require 'gaman/logging'
require 'gaman/message/welcome'
require 'gaman/message/own_info'
require 'gaman/message/motd'
require 'gaman/message/who_info'
require 'gaman/message/login'
require 'gaman/message/logout'

module Gaman
  # Interal: defines the types of messages received from FIBS.
  module MessageType
    # defined by the FIBS CLIP
    OTHER        = 0
    WELCOME      = 1
    OWN_INFO     = 2
    MOTD_START   = 3
    MOTD_END     = 4
    WHO_INFO     = 5
    WHO_INFO_END = 6
    LOGIN        = 7
    LOGOUT       = 8
  end

  # Intenal: Accepts the messages from FIBS as individual lines, and builds
  # them in to Gaman::Message objects as required. This may involve collecting
  # multiple lines from FIBS into a single message (e.g.: MOTD).
  class MessageFactory
    include Logging

    @collecting = false
    @collected_text = ''

    def parse(line)
      # ignore blank lines between commands:
      return nil if !@collecting && line =~ /^\s*$/
      if line =~ /^\d+/
        parse_numbered_line(line)
      elsif @collecting
        @collected_text += line
        nil
      else
        logger.error { "Unknown message: #{line}" }
        nil
      end
    end

    def parse_numbered_line(line)
      type_txt, body = line.split(' ', 2)
      case type_txt.to_i
      when MessageType::WELCOME      then Gaman::Message::Welcome.new(body)
      when MessageType::OWN_INFO     then Message::OwnInfo.new(body)
      when MessageType::MOTD_START
        @collecting = true
        @collected_text = ''
        nil
      when MessageType::MOTD_END
        @collecting = false
        Message::Motd.new @collected_text
      when MessageType::WHO_INFO     then Message::WhoInfo.new(body)
      when MessageType::WHO_INFO_END then nil # nop
      when MessageType::LOGIN        then Message::Login.new(body)
      when MessageType::LOGOUT       then Message::Logout.new(body)
      else
        logger.error { "Message type [#{type_txt}] is unknown: #{line}" }
      end
    end
  end
end
