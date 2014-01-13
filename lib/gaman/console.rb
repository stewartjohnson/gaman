require 'curses'

module Gaman
  class Console < Curses::Window
    @mutex = nil

    def setup
      @mutex.synchronize do 
        attrset Curses::A_REVERSE
        setpos 0, 0
        addstr " "*maxx
        attrset(Curses::A_NORMAL) 
        refresh 
      end
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

    def get_character
      char = nil
      loop do
        @mutex.synchronize { char = getch }
        break if char 
      end
      char
    end
      
    def run mutex, input_queue, output_queue
      @mutex = mutex
      setup
      running = true
      while running
        command = input_queue.pop # blocks
        case command[:type]
        when :quit then running = false
        when :get_string
          display_prompt command[:prompt]
          input = get_character
          output_queue << { :name => command[:output], :value => input, :type => :string }
        end
      end
    end
  end
end