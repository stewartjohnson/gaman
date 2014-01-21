require 'curses'
require 'gaman/logging'

module Gaman
  class Display < Curses::Window

    include Logging

    @mutex = nil

    def display_message text
      @mutex.synchronize do
        box_width = 60
        welcome_win = subwin 20, box_width, 10, ((maxx-box_width)/2).to_i
        welcome_win.setpos 0, 0
        welcome_win.addstr text
        welcome_win.refresh
        welcome_win.timeout = 0
        welcome_win.keypad = true
        refresh
      end
    end

    def setup
      @mutex.synchronize do
        attrset(Curses::A_REVERSE)
        setpos 0, 0
        addstr " "*maxx
        setpos 0, 1
        addstr "Gaman v#{Gaman::VERSION}"
        attrset(Curses::A_NORMAL)  
        self.timeout = 0  
        self.keypad = true  
        refresh
      end
    end

    def run mutex, input_queue
      logger.debug { "Starting up display" }
      @mutex = mutex
      setup
      running = true
      while running
        command = input_queue.pop # blocks
        case command[:type]
        when :quit then running = false
        when :login
          display_message %q{Welcome to Gaman!

Gaman is a console client for playing backgammon on FIBS -  the First Internet Backgammon Server. Gaman was designed to make playing via the console easier, and also as a tribute  to the email client PINE.

To get started you'll need an account on FIBS (fibs.com). 

Please enter your account details below.
(These will be stored in plaintext in $HOME/.gamanrc).}
          # (0..20).to_a.each do |i|
          #   display_message "The counter is now [#{i}]."
          #   sleep 1
          # end
        when :debug
          display_message "The result was [#{command[:value]}]"
        end
        refresh
      end
    end
  end
end