require 'gaman/logging'
require 'gaman/state'
require 'gaman/message_factory'
require 'net/telnet'

module Gaman
  # Public: Provides the ability to connect to the First Internet
  #   Backgammon Server (FIBS).
  class Fibs
    include Logging

    private_class_method :new # hide the default constructor,
                              # consumers should use #use

    attr_accessor :read_thread

    def self.use(*options)
      fibs = new(*options)
      fibs.read_thread = Thread.new { fibs.read }
      fibs.connect
      yield fibs
    ensure
      fibs.close
      Thread.kill fibs.read_thread
    end

    def initialize(user_options)
      @state = Gaman::State.new(user_options)
      @connection = begin
                      Net::Telnet.new 'Host' => 'fibs.com',
                                      'Port' => 4321,
                                      'Output_log' => 'fibs.log'
                    rescue
                      nil
                    end
      @connected = false
    end

    def connect
      return false if @connection.nil?
      # TODO: can we signal from the read thread to here?
      @connection.puts("login Gaman 1008 #{@state.credentials}" +
        "#{@state.user(:username)} #{@state.user(:password)}")
      @connected = true
    end

    def connected?
      !@connection.nil? && @connected
    end

    def username
      @state.user(:username)
    end

    def user(key)
      @state.user(key)
    end

    def players
      @state.players
    end

    def active_players
      @state.active_players
    end

    def close
      logger.debug { 'Logging out' }
      unless @connection.nil?
        logger.debug { 'Sending logout commands' }
        @connection.puts('bye') { |c| logger.debug c }
        @connection.close
      end

      logger.debug { 'Disconnected from FIBS' }
    end

    def read
      factory = MessageFactory.new
      input = ''
      loop do
        input += @connection.waitfor(/\n/)
        while input =~ /\n/
          line, input = input.split("\n", 2)
          msg = factory.parse(line)
          msg.update(@state) if msg
        end
      end
    end
  end
end
