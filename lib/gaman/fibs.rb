require 'gaman/logging'
require 'gaman/fibs_messaging'
require 'gaman/state'
require 'gaman/clip_factory'
require 'net/telnet'

module Gaman
  # Provides the ability to connect to the First Internet Backgammon Server
  # (FIBS). See the included modules {Gaman::FibsMessaging} for functionality
  # provided by this object.
  #
  # @example Connect to FIBS and shout to all players
  #   Gaman::Fibs.use(options) do |fibs|
  #     fibs.shout("This message is shouted to everybody.")
  #   end
  # @api fibs
  class Fibs
    include Logging
    include FibsMessaging

    private_class_method :new

    # @api private
    attr_accessor :read_thread

    # Create a new instance of Fibs that can be used to interact with FIBS.
    #
    # @param [Hash] options the options for connecting to FIBS.
    # @option options [String] :username username for FIBS account.
    # @option options [String] :password password for FIBS account.
    def self.use(options)
      fibs = new(options)
      fibs.read_thread = Thread.new { fibs.read }
      fibs.read_thread.abort_on_exception = true
      fibs.connect
      yield fibs
    ensure
      fibs.close
      Thread.kill fibs.read_thread
    end

    # The default constructor is only used by the #use method so that the Fibs
    # object is correctly disposed after use.
    # @api private
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

    # Registers a block that will be called whenever an event happens for a
    # particular subject.  The block will be called with two parameters: the
    # subject that changed, and the payload for that particular subject
    # (payload is subject dependent).
    # @return [void]
    #
    # @example Register a block to be called when a shout is received
    #   fibs.on_change(:shout) do |message|
    #     puts "A shout was received from #{message.from}: #{message.text}"
    #   end
    def on_change(subject, &block)
      @notify_blocks[subject] << block
    end

    # Registers an object to be notified of changes for a particular subject.
    # A subject is a particular kind of event that can happen on FIBS, such as
    # a :shout or an :invite. The listener is an object that response to the
    # #receive message.
    #
    # The listener will have its #receive method called, and two parameters
    # will be passed: the subject that changed, and the payload for that
    # particular subject (payload is subject dependent).
    #
    # @example Register a listener
    #   class Listener
    #     def receive(subject, payload)
    #       puts "Received notification of #{subject}."
    #     end
    #   end
    #   listener = Listener.new
    #   fibs.register_listener(:shout, listener)
    def register_listener(subject, listener)
      @listeners[subject] << listener
    end

    # Queries whether the connection to FIBS is still active.
    #
    # @return [bool] true if still connected to FIBS.
    def connected?
      !@connection.nil? && @connected
    end

    # The username being used for the FIBS connection.
    # @return [String] the FIBS username.
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

    # Close the connection to FIBS.
    # @api private
    def close
      logger.debug { 'Logging out' }
      unless @connection.nil?
        logger.debug { 'Sending logout commands' }
        @connection.puts('bye') { |c| logger.debug c }
        @connection.close
      end

      logger.debug { 'Disconnected from FIBS' }
    end

    # Connect to FIBS.
    # @api private
    def connect
      return false if @connection.nil?
      # TODO: can we signal from the read thread to here?
      # TODO: handle the new 'alert' message
      @connection.puts("login Gaman 1009 #{@state.credentials}")
      @connected = true
    end

    # Reads continuously from the telnet connection to FIBS and processes all
    # the messages received. Each message is used to update the {Gaman::State}
    # that reflects the current state of FIBS.
    # @api private
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

    # Receives updates from the {Gaman::State} object that represents the
    # current state of FIBS.
    # @api private
    def receive_update(subject, payload)
      @notify_blocks[subject].each { |block| block[payload] }
      @listeners[subject].each { |l| l.receive(subject, payload) }
    end
  end
end
