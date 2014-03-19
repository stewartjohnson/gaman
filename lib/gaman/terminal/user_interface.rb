require 'curses'
require 'gaman/terminal/console'
require 'gaman/terminal/display'
require 'gaman/terminal/command'
require 'gaman/logging'

module Gaman::Terminal
  # Internal: The CLI-based user interface for Gaman.
  class UserInterface
    MIN_ROWS = 40
    MIN_COLS = 80

    include Gaman::Logging

    attr_accessor :thread

    private_class_method :new # hide the default constructor,
                              # consumers should use ConsoleUserInterface#use
    def self.use
      ui = new
      ui.thread = Thread.new { ui.run }
      ui.thread.abort_on_exception = true
      yield ui
    ensure
      Thread.kill ui.thread
      ui.close
    end

    def close
      Curses.close_screen
    end

    def initialize
      @input_queue = Queue.new
      @output_queue = Queue.new

      init_curses

      @display = Display.new Curses.lines - 3, Curses.cols, 0, 0
      @console = Console.new 3, Curses.cols, Curses.lines - 3, 0
      @display.setup
      @console.setup
    end

    def init_curses
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

    def display(screen_id, data=nil)
      @input_queue << { type: :display, value: screen_id, data: data }
    end

    def status(status_id)
      @input_queue << { type: :status, value: status_id }
    end

    def title(text)
      @input_queue << { type: :title, value: text }
    end

    def enter_command_mode(*command_list)
      @input_queue << { type: :commands, value: command_list }
    end

    def command(block = false)
      logger.debug { "waiting cmd: #{block ? "blocking" : "not blocking"}" }
      # TODO: check to see what is on the queue -- command or string?
      return nil if !block && @output_queue.empty?
      @output_queue.pop # blocks
    end

    def enter_text_mode(prompt_id)
      @input_queue << { type: :prompt, value: prompt_id }
    end

    def text(block = false)
      logger.debug { "waiting text: #{block ? "blocking" : "not blocking"}" }
      # TODO: check to see what is on the queue -- command or string?
      return nil if !block && @output_queue.empty?
      @output_queue.pop # blocks
    end

    def run
      loop do
        # the run loop never blocks -- the UI is refreshed and read for UI
        # continuously as fast as possible.

        ## first check for a new task to execute
        task = @input_queue.pop(true) rescue nil # rubocop:disable RescueModifier, LineLength
        if task
          case task[:type]
          when :display # change the display
            logger.debug { "display requested of #{task[:value]}" }
            @display.screen task[:value], task[:data]
          when :status # update the status line with a message
            logger.debug { "status update of #{task[:value]}" }
            @console.status task[:value]
          when :title # set the text in the title bar
            @display.write_title task[:value]
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

        receive_command
        receive_text
      end
    end

    private

    def receive_command
      ## check to see if a command was entered
      cmd = @console.read_command # non-blocking
      @output_queue << cmd if cmd
    end

    def receive_text
      ## check to see if a string has been entered
      # non-blocking - returns:
      #  - nil if nothing ready yet
      #  - false if the user cancelled
      #  - a string if the user entered some text
      val = @console.text
      @output_queue << val if val # it's a string
      @output_queue << nil if !val.nil? && !val
    end
  end
end