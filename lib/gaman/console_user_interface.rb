require 'curses'
require 'gaman/console'
require 'gaman/display'
require 'gaman/command'
require 'gaman/logging'

module Gaman
  # Internal: The CLI-based user interface for Gaman.
  class ConsoleUserInterface
    MIN_ROWS = 40
    MIN_COLS = 80

    include Logging

    attr_accessor :thread

    private_class_method :new # hide the default constructor,
                              # consumers should use ConsoleUserInterface#use
    def self.use
      ui = new
      ui.thread = Thread.new { ui.run }
      yield ui
    ensure
      Thread.kill ui.thread
      ui.close
    end

    def close
      # cleanup
      Curses.close_screen
    end

    def initialize
      # these don't need to be seen by users of this class.
      # the queues are an internal implementation.
      @input_queue = Queue.new
      @output_queue = Queue.new

      logger.debug { 'Starting.' }
      init_curses

      @display = Display.new Curses.lines - 3, Curses.cols, 0, 0
      @console = Console.new 3, Curses.cols, Curses.lines - 3, 0
      @display.setup
      @console.setup
    end

    def init_curses
      logger.debug 'Initialising curses'
      Curses.init_screen
      if Curses.lines < MIN_ROWS || Curses.cols < MIN_COLS
        fail ArgumentError, I18n.t(:screen_size_error)
      end

      # curses initialisation (default states)
      Curses.timeout = 0 # don't block waiting for input
      Curses.curs_set 0  # don't display the cursor
      Curses.noecho      # don't echo input to the console
      Curses.raw         # pass everything through to this program
    end

    def display(screen_id)
      @input_queue << { type: :display, value: screen_id }
    end

    def set_commands(*command_list)
      @input_queue << { type: :commands, value: command_list }
    end

    def get_command(block = false)
      logger.debug { "waiting cmd: #{block ? "blocking" : "not blocking"}" }
      # TODO: check to see what is on the queue -- command or string?
      return nil if !block && @output_queue.empty?
      @output_queue.pop # blocks
    end

    def set_prompt(prompt_id)
      @input_queue << { type: :prompt, value: prompt_id }
    end

    def get_text(block = false)
      logger.debug { "waiting text: #{block ? "blocking" : "not blocking"}" }
      # TODO: check to see what is on the queue -- command or string?
      return nil if !block && @output_queue.empty?
      @output_queue.pop # blocks
    end

    def run
      logger.debug { 'console ui: separate run thread starting' }
      loop do
        # the run loop never blocks -- the UI is refreshed and read for UI
        # continuously as fast as possible.

        ## first check for a new task to execute
        task = @input_queue.pop(true) rescue nil # rubocop:disable RescueModifier LineLength
        if task
          case task[:type]
          when :display # change the display
            logger.debug { "display requested of #{task[:value]}" }
            @display.screen task[:value]
          when :commands
            logger.debug { 'commands provided for display' }
            @console.clear
            @console.commands task[:value]
          when :prompt
            logger.debug { 'settting the console prompt' }
            @console.clear
            @console.display_prompt task[:value]
          else
            fail ArgumentError, "task type of #{task[:type]} not supported by UI"
          end
        end

        ## check to see if a command was entered
        cmd = @console.read_command # non-blocking
        @output_queue << cmd if cmd

        ## check to see if a string has been entered
        begin
          text = @console.get_text # non-blocking
          @output_queue << text if text # FIXME: can get rid of this exception -- use false
        rescue Gaman::Console::Error::CancelInput
          @output_queue << nil
        end
      end
    end
  end
end
