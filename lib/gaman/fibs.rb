require 'gaman/logging'
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

    def initialize(options)
      @username = options[:username]
      @password = options[:password]
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
      @connection.puts("login Gaman 1008 #{@username} #{@password}")
      @connected = true
    end

    def connected?
      !@connection.nil? && @connected
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

    def motd
      'This is the MOTD text.'
    end

    def read
      input = ''
      loop do
        input += @connection.waitfor(/\n/)
        while input =~ /\n/
          line, input = input.split("\n", 2)
          logger.debug { "Read thread received: #{line}" }
        end
      end
    end
  end
end
