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

    attr_accessor :thread

    private_class_method :new # hide the default constructor, 
                              # consumers should use ConsoleUserInterface#use

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

    # Calling the use method on the class creates a new instance and launches
    # it in a thread by itself. Once execution is finished resources are
    # disposed properly.
    def self.use
      ui = new
      ui.thread = Thread.new do
        ui.run # go play in your own thread
      end
      yield ui
    ensure
      Thread.kill ui.thread
      ui.close
    end

    def close
      #cleanup
      Curses.close_screen
    end

    def initialize
      # these don't need to be seen by users of this class.
      # the queues are an internal implementation.
      @input_queue = Queue.new
      @output_queue = Queue.new

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
      @display.setup
      @console.setup
    end

    def display screen_id
      @input_queue << { :type => :display, :value => screen_id }
    end

    def commands *command_list
      @input_queue << { :type => :commands, :value => command_list }
    end

    def wait_for_command
      logger.debug { 'waiting for command'}
      @output_queue.pop
    end

    def run
      loop do
        # the run loop never blocks -- the UI is refreshed and read for UI continuously
        # as fast as possible.

        ## first check for a new task to execute
        task = @input_queue.pop(true) rescue nil
        if task
          case task[:type]
          when :display # change the display
            logger.debug { "display requested of #{task[:value]}"}
            @display.screen task[:value]
          when :commands
            logger.debug { "commands provided for display"}
            @console.commands task[:value]
          else
            raise ArgumentError, "task type of #{task[:type]} not supported by UI"
          end
        end

        ## check to see if a command was entered s
        if cmd = @console.read_command # non-blocking
          logger.debug { "ui curses thread: received cmd #{cmd}"}
          @output_queue << cmd
        end
      end
    end

  end
end