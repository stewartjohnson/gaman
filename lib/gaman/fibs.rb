require 'gaman/logging'
require 'gaman/state'
require 'gaman/clip_factory'
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
      fibs.read_thread.abort_on_exception = true
      fibs.connect
      yield fibs
    ensure
      fibs.close
      Thread.kill fibs.read_thread
    end

    def initialize(user_options)
      @state = Gaman::State.new(user_options, &method(:receive_update))
      @notify_blocks = Hash.new { |hash, key| hash[key] = [] }
      @listeners = Hash.new { |hash, key| hash[key] = [] }

      @connection = begin
                      Net::Telnet.new 'Host' => 'fibs.com',
                                      'Port' => 4321,
                                      'Timeout' => false,
                                      'Output_log' => 'fibs.log'
                    rescue
                      nil
                    end
      @connected = false
    end

    def on_change(*subjects, &block)
      subjects.each { |subject| @notify_blocks[subject] << block }
    end

    def register_listener(subject, listener)
      @listeners[subject] << listener
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

    # Internal: retrieves a list of messages that match the specified options.
    def messages(options)
      @state.messages(options)
    end

    def shout(message)
      @connection.puts("shout #{message}")
    end

    def tell(name, message)
      @connection.puts("tell #{name} #{message}")
    end

    def whisper(message)
      @connection.puts("whisper #{message}")
    end

    def kibitz(message)
      @connection.puts("kibitz #{message}")
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

    def connect
      return false if @connection.nil?
      # TODO: can we signal from the read thread to here?
      # TODO: handle the new 'alert' message
      @connection.puts("login Gaman 1009 #{@state.credentials}")
      @connected = true
    end

    def read
      factory = ClipFactory.new
      input = ''
      loop do
        input += @connection.waitfor(/\n/)
        while input =~ /\n/
          line, input = input.split("\n", 2)
          clip = factory.parse(line)
          clip.update(@state) if clip
        end
      end
    end

    def receive_update(subject, payload)
      @notify_blocks[subject].each { |block| block[subject, payload] }
      @listeners[subject].each { |l| l.receive(subject, payload) }
    end
  end
end
