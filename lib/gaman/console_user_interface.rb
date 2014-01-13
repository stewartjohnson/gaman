require 'curses'
require 'gaman/console'
require 'gaman/display'

module Gaman
  class ConsoleUserInterface
    MIN_ROWS = 40
    MIN_COLS = 80


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

    def initialize
      Curses.init_screen
      if Curses.lines < MIN_ROWS || Curses.cols < MIN_COLS
        raise ArgumentError, "Your terminal needs to be at least #{MIN_ROWS} lines and #{MIN_COLS} columns."
      end

      # curses initialisation (default states)
      Curses.timeout = 0 # don't block waiting for input
      Curses.curs_set 0  # don't display the cursor

      @display = Display.new Curses.lines-3, Curses.cols, 0, 0 
      @console = Console.new 3, Curses.cols, Curses.lines-3, 0

      ## create and run the two threads for display and io
      @display_input_queue = Queue.new
      @console_input_queue = Queue.new
      @console_output_queue = Queue.new
      @curses_mutex = Mutex.new

      @threads = []
      @threads << Thread.new(@curses_mutex, @display_input_queue) do |mutex, input_queue|
        @display.run mutex, input_queue
      end
      @threads << Thread.new(@curses_mutex, @console_input_queue, @console_output_queue) do |mutex, input_queue, output_queue|
        @console.run mutex, input_queue, output_queue
      end
    end


    def login
      @display_input_queue << { :type => :login }
      @console_input_queue << { :type => :get_string, :prompt => "FIBS username:", :max => 20, :output => :username }
      result = @console_output_queue.pop
      @display_input_queue << { :type => :debug, :value => result[:value] }
      sleep 2
    end

    def close
      #cleanup
      @display_input_queue << { :type => :quit }
      @console_input_queue << { :type => :quit }
      @threads.each { |t| t.join }
      @display.close
      @console.close
    end
  end
end