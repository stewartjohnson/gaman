require 'curses'
require 'gaman/logging'
require 'gaman/terminal/screen'

module Gaman::Terminal
  # Internal: Implements the 'display' part of the CLI window.
  class Display < Curses::Window
    include Gaman::Logging

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

    def display_player_list(players)
      attrset(Curses::A_NORMAL)
      player_names = players.keys
      sorted_player_names = player_names.sort do |a, b|
        # sort by rating by default
        players[b][:rating] <=> players[a][:rating]
      end
      sorted_player_names[0..(maxy - 5)].each_with_index do |player_name, i|
        setpos 2 + i, 1
        addstr '%-20s' % player_name +
          '%.2f ' % players[player_name][:rating] +
          '%8d ' % players[player_name][:experience] +
          "#{players[player_name][:ready] ? 'ready ' : '      '}" +
          "#{players[player_name][:away] ? 'away ' : '     '}" +
          '%-20s' % players[player_name][:opponent] +
          '%-30s' % players[player_name][:client]
      end
      refresh
    end

    def screen(screen_id, data=nil)
      case screen_id
      when Screen::LOGIN
        display_message I18n.t(:welcome_text)
      when Screen::PLAYER_LIST
        display_player_list(data)
      when Screen::MAIN
        display_message I18n.t(:main_text)
      when Screen::MESSAGING
        display_shouts
      else
        fail ArgumentError, "Unknown screen #{screen_id}"
      end
    end
  end
end
