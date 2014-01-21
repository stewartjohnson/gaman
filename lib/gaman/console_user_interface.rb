require 'curses'
require 'gaman/console'
require 'gaman/display'
require 'gaman/command'
require 'gaman/logging'

module Gaman

  class ConsoleUserInterface
    MIN_ROWS = 40
    MIN_COLS = 80

    include Logging


    # console UI is divided into two windows:
    #
    # - everything but the bottom 3 rows is the 'display': it is where the  current 
    #   status/explanation resides. It is updated in it's own thread based on a queue, the queue 
    #   contains commands on what to display. e.g.: 'display login screen', 'display shout screen',
    #   'display options screen', 'display game sceren'.
    # - the bottom three rows is the 'console': this displays the available commands being accepted
    #   by the system at the moment, and accepts the input. The input is usually a single keypress
    #   to issue a command (e.g.: 'I' to invite someon, 'Q' to quit) but it can also be text entry:
    #   e.g.: the username, the name of a player, or the message to send to another player.
    #
    # Each of the two subwindows is controlled by a different thread. They share a common mutex to 
    # best deal with the fact that ncurses is not threadsafe. The 'console' thread makes non-blocking
    # requests for input and then sleeps momentarily so that the display thread may access the 
    # Curses library to make calls. This should mean that the Curses library will only ever see one 
    # thread of execution at a time, though it will see multiple threads separately.

    def onsig(sig)
      close_screen
      exit sig
    end

    def initialize

      ## disable signals from exiting this program 
      # TODO trap ctrl-c to do a graceful exit
      # for i in 1 .. 15  # SIGHUP .. SIGTERM
      #   # this currently throws an ArugmentError for SIGILL (what is that?)
      #   # better to use specifically named signals for control-C and ESC rather
      #   # than just ignoring everything (all signals)?
      #   if trap(i, "SIG_IGN") != 0 then  # 0 for SIG_IGN
      #     trap(i) {|sig| onsig(sig) }
      #   end
      # end

      logger.debug { "Starting." }
      Curses.init_screen
      if Curses.lines < MIN_ROWS || Curses.cols < MIN_COLS
        raise ArgumentError, "Your terminal needs to be at least #{MIN_ROWS} lines and #{MIN_COLS} columns."
      end

      # curses initialisation (default states)
      Curses.timeout = 0 # don't block waiting for input
      Curses.curs_set 0  # don't display the cursor
      Curses.noecho      # don't echo input to the console
      Curses.raw         # pass everything through to this program

      @display = Display.new Curses.lines-3, Curses.cols, 0, 0 
      @console = Console.new 3, Curses.cols, Curses.lines-3, 0

      ## create and run the two threads for display and io
      @display_input_queue = Queue.new
      @console_input_queue = Queue.new
      @console_output_queue = Queue.new
      @curses_mutex = Mutex.new

      @threads = []
      @threads << Thread.new("display", @curses_mutex, @display_input_queue) do |name, mutex, input_queue|
        Thread.current[:name] = name
        @display.run mutex, input_queue
      end
      @threads << Thread.new("console", @curses_mutex, @console_input_queue, @console_output_queue) do |name, mutex, input_queue, output_queue|
        Thread.current[:name] = name
        @console.run mutex, input_queue, output_queue
      end
    end

    ## display the login screen and prompt for FIBS account details
    def login
      username = password = nil
      while username.nil? || password.nil? do
        display :login
        # this blocks and waits for command
        result = commands(Command.new('Q', :quit, "Quit Garman"), Command.new('L', :login, "Enter FIBS Login"))
        return if result == :quit   # result can only be Quit or Login

        # user has asked to login
        username = get_string "Please enter FIBS username:" # blocks
        next unless username
        password = get_string "Please enter FIBS password:" # blocks
      end

      status "Details: username = #{username} Password = #{password}"
      sleep 5
      [username, password]
    end

    def close
      #cleanup
      @display_input_queue << { :type => :quit }
      @console_input_queue << { :type => :quit }
      @threads.each { |t| t.join }
      @display.close
      @console.close
    end

    private

    def get_string prompt, max_length = 20
      @console_input_queue << { :type => :get_string, :prompt => prompt, :max_length => max_length }
      @console_output_queue.pop # blocks
    end

    def display screen
      @display_input_queue << { :type => screen }
    end

    def commands *commands
      @console_input_queue << { :type => :commands, :commands => commands }
      @console_output_queue.pop # blocks
    end

    def status message
      @console_input_queue << { :type => :status, :message => message }
    end

  end
end