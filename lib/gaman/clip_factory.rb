require 'gaman/logging'
require 'gaman/clip/welcome'
require 'gaman/clip/own_info'
require 'gaman/clip/motd'
require 'gaman/clip/who_info'
require 'gaman/clip/login'
require 'gaman/clip/logout'
require 'gaman/clip/message'
require 'gaman/clip/message_delivered'
require 'gaman/clip/says'
require 'gaman/clip/shouts'
require 'gaman/clip/whispers'
require 'gaman/clip/kibitzes'
require 'gaman/clip/you_say'
require 'gaman/clip/you_shout'
require 'gaman/clip/you_whisper'
require 'gaman/clip/you_kibitz'

module Gaman
  # Interal: defines the types of messages received from FIBS.
  module ClipType
    # defined by the FIBS CLIP
    OTHER             =  0
    WELCOME           =  1
    OWN_INFO          =  2
    MOTD_START        =  3
    MOTD_END          =  4
    WHO_INFO          =  5
    WHO_INFO_END      =  6
    LOGIN             =  7
    LOGOUT            =  8
    MESSAGE           =  9
    MESSAGE_DELIVERED = 10
    MESSAGE_SAVED     = 11
    SAYS              = 12
    SHOUTS            = 13
    WHISPERS          = 14
    KIBITZES          = 15
    YOU_SAY           = 16
    YOU_SHOUT         = 17
    YOU_WHISPER       = 18
    YOU_KIBITZ        = 19
    ALERT             = 20
  end

  # Intenal: Accepts the CLIP messages from FIBS as individual lines, and
  # builds them in to Gaman::Clip objects as required. This may involve
  # collecting multiple lines from FIBS into a single CLIP (e.g.: MOTD).
  class ClipFactory
    include Logging

    @collecting = false
    @collected_text = ''

    def parse(line)
      # ignore blank lines between commands:
      return nil if !@collecting && line =~ /^\s*$/
      if line =~ /^\d+/
        parse_clip_line(line)
      elsif @collecting
        @collected_text += line
        nil
      else
        logger.error { "Unknown CLIP: #{line}" }
        nil
      end
    end

    def parse_clip_line(line)
      type_txt, body = line.split(' ', 2)
      case type_txt.to_i
      when ClipType::MOTD_START
        @collecting = true
        @collected_text = ''
        nil
      when ClipType::MOTD_END
        @collecting = false
        Clip::Motd.new @collected_text
      when ClipType::WHO_INFO_END      then nil # nop
      # TODO: I should be able to fold all the cases below into some generic
      # code. If one of these message types, then get the corresponding class
      # name from the constant name (method on the ClipType module), then
      # create new instance and pass it the body.
      when ClipType::WELCOME           then Clip::Welcome.new(body)
      when ClipType::OWN_INFO          then Clip::OwnInfo.new(body)
      when ClipType::WHO_INFO          then Clip::WhoInfo.new(body)
      when ClipType::LOGIN             then Clip::Login.new(body)
      when ClipType::LOGOUT            then Clip::Logout.new(body)
      when ClipType::MESSAGE           then Clip::Message.new(body)
      when ClipType::MESSAGE_DELIVERED then Clip::MessageDelivered.new(body)
      when ClipType::MESSAGE_SAVED     then Clip::MessageSaved.new(body)
      when ClipType::SAYS              then Clip::Says.new(body)
      when ClipType::SHOUTS            then Clip::Shouts.new(body)
      when ClipType::WHISPERS          then Clip::Whispers.new(body)
      when ClipType::KIBITZES          then Clip::Kibitzes.new(body)
      when ClipType::YOU_SAY           then Clip::YouSay.new(body)
      when ClipType::YOU_SHOUT         then Clip::YouShout.new(body)
      when ClipType::YOU_WHISPER       then Clip::YouWhisper.new(body)
      when ClipType::YOU_KIBITZ        then Clip::YouKibitz.new(body)
      # TODO: implement 'alert' message (messages from Patti)
      when ClipType::ALERT             then fail NotImplementedError
      else
        logger.error { "CLIP type [#{type_txt}] is unknown: #{line}" }
      end
    end
  end
end
