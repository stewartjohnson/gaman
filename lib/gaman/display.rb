require 'curses'
require 'gaman/logging'
require 'gaman/screen'

module Gaman
  class Display < Curses::Window

    include Logging

    def setup
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

    def display_message text
      box_width = 60
      welcome_win = subwin 20, box_width, 10, ((maxx-box_width)/2).to_i
      welcome_win.setpos 0, 0
      welcome_win.addstr text
      welcome_win.refresh
      welcome_win.timeout = 0
      welcome_win.keypad = true
      refresh
    end

    def screen screen_id
      case screen_id
      when Screen::Login
        display_message I18n.t(:welcome_text)
      else
        raise ArgumentError, "Unknown screen #{screen_id}"
      end
    end

  end
end