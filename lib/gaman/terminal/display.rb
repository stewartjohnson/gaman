require 'curses'
require 'gaman/logging'
require 'gaman/terminal/screen'

# Internal: Implements the 'display' part of the CLI window.
class Gaman::Terminal::Display < Curses::Window
  include Gaman::Logging

  def setup
    write_title
    self.timeout = 0
    self.keypad = true
    refresh
  end

  def display_message(text, box_width=60, box_height=20)
    welcome_win = subwin box_height, box_width, 10, ((maxx - box_width) / 2).to_i
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

  def dialog(options)
    clear
    text = options[:text]
    width = options[:width] || maxx - 20
    height = options[:height] || maxy - 5
    win = subwin height, width, ((maxy - height) / 2).to_i, ((maxx - width) / 2).to_i
    win.setpos 0, 0
    win.addstr text
    refresh
  end

  def screen(screen_id, data=nil)
    fail ArgumentError, "Unknown screen #{screen_id}"
  end
end
