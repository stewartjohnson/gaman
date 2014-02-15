require 'curses'
require 'gaman/logging'
require 'gaman/console_mode'

module Gaman

  class Console < Curses::Window

    include Logging

    def setup
      self.timeout = 0 # ms to block on each read
      self.keypad = true
      attrset Curses::A_REVERSE
      setpos 0, 0
      addstr " "*maxx
      attrset(Curses::A_NORMAL) 
      refresh

      @ui_mode = ConsoleMode::None
      @result = "" 
    end

    def commands command_list
      # TODO handle two rows of commands
      @ui_mode = ConsoleMode::Command
      setpos 1,0
      command_list.each do |cmd|
        attrset Curses::A_REVERSE
        addstr Command.key(cmd)
        attrset Curses::A_NORMAL
        addstr "%-20s" % " #{Command.label(cmd)}"
      end
      refresh
    end

    def clear
      attrset Curses::A_NORMAL
      setpos 1, 0 # start of first line under status bar
      clrtoeol
      setpos 2,0 # start of second line under status bar
      clrtoeol
      setpos 1, 0 # start of first line under status bar
      refresh
    end

    def read_command
      return nil unless @ui_mode == ConsoleMode::Command
      char = getch
      if char && char[0].ord > 30 # received a non-control character
        # convert the char to the Command
        logger.debug { "console: received command key #{char}"}
        cmd = Command.from_key(char)
        @ui_mode = ConsoleMode::None
        logger.debug { "console: command received was #{cmd.nil? ? 'not valid' : cmd}"}
        cmd
      end
    end

    def display_prompt prompt_id
      @ui_mode = ConsoleMode::Text
      @result = ""
      attrset Curses::A_REVERSE
      setpos 0, 0
      text = Prompt.text(prompt_id)
      addstr text + " "*(maxx-text.size)
      attrset Curses::A_NORMAL
      refresh 
    end

    def get_text
      # return nil if the user hits ESC
      # need to set the location of the cursor and show it
      # need to echo the characters that are being typed (manually - noecho should remain on)
      # need to support arrow keys and delete properly

      return nil unless @ui_mode == ConsoleMode::Text

      complete_string = false

      Curses.curs_set 1
      char = getch 
      Curses.curs_set 0
      
      if char
        logger.debug {"Received key. [#{char}] Ord: [#{char[0].ord}] Int: [#{char[0].to_i}]"} 

        case char
        when 10
          logger.debug {"ENTER detected"}
          complete_string = true
        when 27
          logger.debug {"ESCAPE detected"}
          raise NotImplementedError "Escape not implemented yet."
          return nil # TODO - this won't work any more
        when 127
          logger.debug {"BACKSPACE detected"}
          # TODO check for @result.size > 0
          setpos cury, curx-1
          addch " "
          setpos cury, curx-1
          @result = @result[0..-2]
        when Curses::Key::BACKSPACE
          logger.debug {"BACKSPACE detected through Curses."}
        when 330
          logger.debug {"DELETE detected"}
        when Curses::Key::LEFT
          logger.debug {"LEFT detected through Curses."}
        when Curses::Key::RIGHT
          logger.debug {"RIGHT detected through Curses."}
        when Curses::Key::UP
          logger.debug {"UP detected through Curses."}
        when Curses::Key::DOWN
          logger.debug {"DOWN detected through Curses."}
        else 
          addch char
          @result += char
        end
        logger.debug "current string is #{@result}"
      end

      @ui_mode = complete_string ? ConsoleMode::None : ConsoleMode::Text

      if complete_string
        logger.debug { "The complete string of #{@result} is ready to pass back" }
      end
      complete_string ? @result : nil  
    end
    
  end
end