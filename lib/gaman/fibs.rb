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
    attr_reader :connected

    def self.use(*options)
      fibs = new(*options)
      fibs.read_thread = Thread.new { fibs.read }
      yield fibs
    ensure
      fibs.close
      Thread.kill fibs.read_thread
    end

    def initialize(options)
      @username = options[:username]
      @password = options[:password]
      logger.debug { "Connecting #{@username}/#{@password}" }
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

      @connection.waitfor('String' => 'login:') { |c| logger.debug c }
      @connection.cmd(
                      'String' => "login Gaman 1008 #{@username} #{@password}",
                      'Match' => /\n/) do |c|
        logger.debug c
      end
      logger.debug { 'Logging in complete' }
      @connected = true
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

    private

    def read
      loop do
        break unless connected?
        @connection.wait_for(/\n/) do |text|
          logger.debug { "Read thread received: #{text[0..20]}" }
        end
      end
    end
  end
end
