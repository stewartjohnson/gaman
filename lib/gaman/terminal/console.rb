require 'curses'
require 'gaman/logging'

module Gaman
  module Terminal
    # Internal: provides the different console mode constants.
    module ConsoleMode
      %w( none command text ).each_with_index do |mode, i|
        const_set(mode.capitalize, i)
      end
    end

    # Internal: Implements the console portion of the CLI.
    class Console < Curses::Window
      include Logging

      def setup
        self.timeout = 0 # ms to block on each read
        self.keypad = true
        attrset Curses::A_REVERSE
        setpos 0, 0
        addstr ' ' * maxx
        attrset(Curses::A_NORMAL)
        refresh

        @ui_mode = ConsoleMode::None
        @current_commands = []
        @result = ''
      end

      def commands(command_list)
        # TODO: handle two rows of commands properly
        @current_commands = command_list
        @ui_mode = ConsoleMode::Command
        setpos 1, 0
        command_list.each do |cmd|
          attrset Curses::A_REVERSE
          addstr Command.key(cmd)
          attrset Curses::A_NORMAL
          addstr(sprintf '%-20s', " #{Command.label(cmd)}")
        end
        refresh
      end

      def clear
        attrset Curses::A_REVERSE
        setpos 0, 0
        addstr ' ' * maxx
        attrset Curses::A_NORMAL
        setpos 1, 0 # start of first line under status bar
        clrtoeol
        setpos 2, 0 # start of second line under status bar
        clrtoeol
        setpos 1, 0 # start of first line under status bar
        refresh
      end

      # Internal: Updates the status bar in the console to display a given
      # message. The message is centred in the status bar line.
      def status(status_id)
        attrset Curses::A_REVERSE
        setpos 0, 0
        addstr ' ' * maxx
        text = Status.text(status_id)
        setpos 0, (maxx - text.length) / 2
        addstr text
        attrset(Curses::A_NORMAL)
        refresh
      end

      # Internal: Reads a command from the user (a single keystroke) and returns
      # as the integer value of that comamnd, as defined by the Command module.
      # The command will only be accepted if it is in the list of commands most
      # recently provided by calling #enter_command_mode.
      def read_command
        return nil unless @ui_mode == ConsoleMode::Command
        char = getch
        if char && char[0].ord > 30 # received a non-control character
          # convert the char to the Command
          logger.debug { "console: received command key #{char}" }
          cmd = Command.from_key(char)
          if !cmd.nil? && @current_commands.include?(cmd)
            @ui_mode = ConsoleMode::None
            logger.debug { "console: command received was #{cmd}" }
            cmd
          else
            logger.debug { 'console: command received was not valid' }
            nil
          end
        end
      end

      def display_prompt(prompt_id)
        @ui_mode = ConsoleMode::Text
        @result = ''
        attrset Curses::A_REVERSE
        setpos 0, 0
        text = Prompt.text(prompt_id)
        addstr text + ' ' * (maxx - text.size)
        attrset Curses::A_NORMAL
        refresh
      end

      def text
        return nil unless @ui_mode == ConsoleMode::Text

        complete_string = false

        Curses.curs_set 1
        char = getch
        Curses.curs_set 0

        if char
          logger.debug { "Received key. [#{char}] Ord: [#{char[0].ord}] Int: [#{char[0].to_i}]" } # rubocop:disable LineLength

          case char
          when 3
            logger.debug { 'Received Ctrl-C' }
            @ui_mode = ConsoleMode::None
            return false
          when 10
            logger.debug { 'ENTER detected' }
            complete_string = true
          when 27
            logger.debug { 'ESCAPE detected' }
          when 127
            logger.debug { 'BACKSPACE detected' }
            setpos cury, curx - 1
            addch ' '
            setpos cury, curx - 1
            @result = @result[0..-2]
          when Curses::Key::BACKSPACE
            logger.debug { 'BACKSPACE detected through Curses.' }
          when 330
            logger.debug { 'DELETE detected' }
          when Curses::Key::LEFT
            logger.debug { 'LEFT detected through Curses.' }
          when Curses::Key::RIGHT
            logger.debug { 'RIGHT detected through Curses.' }
          when Curses::Key::UP
            logger.debug { 'UP detected through Curses.' }
          when Curses::Key::DOWN
            logger.debug { 'DOWN detected through Curses.' }
          else
            addch char
            @result += char
          end
          logger.debug "current string is #{@result}"
        end

        @ui_mode = complete_string ? ConsoleMode::None : ConsoleMode::Text

        complete_string ? @result : nil
      end
    end
  end
end
