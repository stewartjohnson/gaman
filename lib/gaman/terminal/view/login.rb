require 'gaman/terminal/command'

module Gaman::Terminal::View
  class Login
    include Gaman::Terminal

    def initialize(ui)
      @ui = ui
      @username = @password = nil
    end

    def activate
      @ui.display Screen::LOGIN
    end

    def next_action
      loop do
        @ui.enter_command_mode Command::QUIT, Command::LOGIN
        cmd = @ui.command(true)
        return cmd if cmd == Command::QUIT
        @ui.enter_text_mode Prompt::USERNAME
        @username = @ui.text(true)
        next if @username.nil?
        @ui.enter_text_mode Prompt::PASSWORD
        @password = @ui.text(true)
        next if @password.nil?
        return Command::LOGIN
      end
    end

    def credentials
      [@username, @password]
    end

    def deactivate
      # nop
    end
  end
end
