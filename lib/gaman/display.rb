require 'curses'
require 'gaman/logging'
require 'gaman/screen'

module Gaman
  # Internal: Implements the 'display' part of the CLI window.
  class Display < Curses::Window
    include Logging

    def setup
      write_title
      self.timeout = 0
      self.keypad = true
      refresh
    end

    def display_message(text)
      box_width = 60
      welcome_win = subwin 20, box_width, 10, ((maxx - box_width) / 2).to_i
      welcome_win.setpos 0, 0
      welcome_win.addstr text
      welcome_win.refresh
      welcome_win.timeout = 0
      welcome_win.keypad = true
      refresh
    end

    def write_title(text = '')
      @title_text = text
      attrset(Curses::A_REVERSE)
      setpos 0, 0
      addstr ' ' * maxx
      setpos 0, 1
      addstr "Gaman v#{Gaman::VERSION}"
      setpos 0, maxx - text.length - 1
      addstr(text)
      attrset(Curses::A_NORMAL)
      refresh
    end

    def screen(screen_id)
      case screen_id
      when Screen::LOGIN
        display_message I18n.t(:welcome_text)
      else
        fail ArgumentError, "Unknown screen #{screen_id}"
      end
    end
  end
end

