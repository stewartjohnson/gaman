require 'curses'
require 'gaman/logging'

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
    end

    def commands command_list
      # TODO handle two rows of commands
      setpos 1,0
      command_list.each do |cmd|
        attrset Curses::A_REVERSE
        addstr Command.key(cmd)
        attrset Curses::A_NORMAL
        addstr "%-20s" % " #{Command.label(cmd)}"
      end
      refresh
    end

    def display_prompt text
      attrset Curses::A_REVERSE
      setpos 0, 0
      addstr text + " "*(maxx-text.size)
      attrset Curses::A_NORMAL
      refresh 
    end

    def read_command
      char = getch
      if char && char[0].ord > 30 # received a non-control character
        logger.debug {"command was received"}
        # convert the char to the Command
        cmd = Command.from_key(char)
        logger.debug { "command received was #{cmd.nil? ? 'nil' : cmd}"}
        cmd
      end
    end

    def get_character valid_keys
      char = nil
      loop do
        char = getch
        break if char && # we received a character
          char[0].ord > 30 && # it's not a control character (e.g.: ESC)
          valid_keys.map { |c| c.downcase }.include?(char.downcase) # it matches the list
      end
      char
    end

    def choose_command commands

      selected_character = get_character(commands.map { |c| c.key })
      selected_command = nil
      commands.each do |c|
        selected_command = c if c.key.downcase == selected_character.downcase
      end
      # selected_command = commands.bsearch { |c| c.key.downcase == selected_character.downcase }
      selected_command.value
    end

    def clear
      # setpos 0, 0
      # addstr " "*maxx
      attrset Curses::A_NORMAL
      setpos 1, 0 # start of first line under status bar
      clrtoeol
      setpos 2,0 # start of second line under status bar
      clrtoeol
      setpos 1, 0 # start of first line under status bar
    end

    def get_string max_length
      # return nil if the user hits ESC
      # need to set the location of the cursor and show it
      # need to echo the characters that are being typed (manually - noecho should remain on)
      # need to support arrow keys and delete properly
      logger.debug { "Asking user for string of max length #{max_length}" }
      result = ""
      clear

      loop do
        char = nil
        loop do
          Curses.curs_set 1
          char = getch 
          Curses.curs_set 0
          break if char 
        end
        case char
        when 10
          logger.debug {"ENTER detected"}
        when 27
          logger.debug {"ESCAPE detected"}
          return nil
        when 127
          logger.debug {"BACKSPACE detected"}
          setpos cury, curx-1
          addch " "
          setpos cury, curx-1
          result = result[0..-2]
          next
        when Curses::Key::BACKSPACE
          logger.debug {"BACKSPACE detected through Curses."}
          next
        when 330
          logger.debug {"DELETE detected"}
          next
        when Curses::Key::LEFT
          logger.debug {"LEFT detected through Curses."}
          next
        when Curses::Key::RIGHT
          logger.debug {"RIGHT detected through Curses."}
          next
        when Curses::Key::UP
          logger.debug {"UP detected through Curses."}
          next
        when Curses::Key::DOWN
          logger.debug {"DOWN detected through Curses."}
          next
        end
        logger.debug "Received key. [#{char}] Ord: [#{char[0].ord}] Int: [#{char[0].to_i}]"
        break if char == 10
        addch char
        result += char
      end
      logger.debug "Received the string #{result}"
      clear
      result
    end
      
  end
end