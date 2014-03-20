require 'gaman/terminal/command'
require 'gaman/logging'

module Gaman::Terminal::View
  class Login
    include Gaman::Terminal
    include Gaman::Logging

    def initialize(ui)
      @ui = ui
      @username = @password = nil
    end

    def activate
      logger.debug { 'calling dialog' }
      @ui.dialog text:   I18n.t(:welcome_text),
                 width:  60,
                 height: 10
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
