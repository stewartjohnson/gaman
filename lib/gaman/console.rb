require 'curses'
require 'gaman/logging'

module Gaman
  class Console < Curses::Window

    include Logging

    @mutex = nil

    def setup
      @mutex.synchronize { 
        attrset Curses::A_REVERSE
        setpos 0, 0
        addstr " "*maxx
        attrset(Curses::A_NORMAL) 
        refresh 
      }
    end

    def display_prompt text
      @mutex.synchronize do
        attrset Curses::A_REVERSE
        setpos 0, 0
        addstr text
        attrset(Curses::A_NORMAL) 
        refresh 
      end
    end

    def get_character valid_keys
      char = nil
      loop do
        @mutex.synchronize { char = getch }
        break if char && # we received a character
          char[0].ord > 30 && # it's not a control character (e.g.: ESC)
          valid_keys.map { |c| c.downcase }.include?(char.downcase) # it matches the list
      end
      char
    end

    def choose_command commands
      @mutex.synchronize do
        setpos 1,0
        commands.each do |c|
          attrset Curses::A_REVERSE
          addstr c.key
          attrset Curses::A_NORMAL
          addstr " #{c.label}" + " "*(19-c.label.size)
        end
      end

      selected_character = get_character(commands.map { |c| c.key })
      selected_command = nil
      commands.each do |c|
        selected_command = c if c.key.downcase == selected_character.downcase
      end
      # selected_command = commands.bsearch { |c| c.key.downcase == selected_character.downcase }
      selected_command.value
    end

    def clear
      @mutex.synchronize do 
        attrset Curses::A_NORMAL
        setpos 1, 0 # start of first line under status bar
        clrtoeol
        setpos 2,0 # start of second line under status bar
        clrtoeol
        setpos 1, 0 # start of first line under status bar
      end
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
          @mutex.synchronize do 
            Curses.curs_set 1
            char = getch 
            Curses.curs_set 0
          end
          break if char 
        end
        break if char == 10
        addch char
        result += char
      end
      logger.debug "Received the string #{result}"
      clear
      result
    end
      
    def run mutex, input_queue, output_queue
      @mutex = mutex
      setup
      running = true
      while running
        command = input_queue.pop # blocks
        case command[:type]
        when :quit then running = false
        when :status
          display_prompt command[:message]
        when :commands 
          output_queue << choose_command(command[:commands])
        when :get_string
          display_prompt command[:prompt]
          output_queue << get_string(command[:max_length])
        end
      end
    end
  end
end