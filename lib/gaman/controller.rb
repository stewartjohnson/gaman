require 'gaman/logging'
require 'gaman/prompt'
require 'gaman/command'
require 'gaman/console_user_interface'
require 'gaman/fibs'

module Gaman
  # Internal: The main controller class for CLI gaman.
  class Controller
    include Logging

    def run
      logger.debug { 'controller: gaman controller starting' }
      Gaman::ConsoleUserInterface.use do |ui|
        loop do
          ui.display Screen::LOGIN
          # TODO: constants should be CAPS
          ui.set_commands Command::Quit, Command::Login
          cmd = ui.get_command(true)
          break if cmd == Command::Quit
          ui.set_prompt Prompt::Username
          username = ui.get_text(true)
          next if username.nil?
          ui.set_prompt Prompt::Password
          password = ui.get_text(true)
          next if password.nil?
          logger.debug { "received credentials: #{username}/#{password}" }

          # ui.status Status::AttemptingConnection
          Gaman::Fibs.use(username: username, password: password) do |fibs|
            if fibs.connect
              ui.status Status::ConnectedSuccessfully
            else
              ui.display Screen::ConnectionError # TODO: error details inserted
              next # back to login screen
            end
          #   ui.commands Command::Quit, Command::Filter
          #   cmd = nil
          #   while cmd.nil? do
          #     ui.display Screen::PlayerList, fibs.player_list
          #     cmd = ui.available_command
          #   end

          #   case cmd
          #   when cmd.quit? then break
          #   when cmd.filter?
          #     # TODO
          #   when cmd.invite?
          #     # TODO
          #   when cmd.resume?
          #     # TODO
          #   else
          #     # ERROR
          #   end
          end
          sleep 10
          break
        end
      end
    end
  end
end
