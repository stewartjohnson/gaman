require 'gaman/logging'
require 'gaman/prompt'
require 'gaman/status'
require 'gaman/command'
require 'gaman/console_user_interface'
require 'gaman/fibs'

module Gaman
  # Internal: The main controller class for CLI gaman.
  class Controller
    include Logging

    def run
      Gaman::ConsoleUserInterface.use do |ui|
        loop do
          break unless display_welcome(ui)
          username, password = prompt_credentials(ui)
          next if username.nil? || password.nil?

          ui.status Status::ATTEMPTING_CONNECTION
          Gaman::Fibs.use(username: username, password: password) do |fibs|
            sleep 5
            if fibs.connected?
              ui.status Status::CONNECTED_SUCCESSFULLY
            else
              # TODO: error details inserted
              ui.display Screen::CONNECTION_ERROR, fibs.last_error
              ui.enter_command_mode Command::RETRY, Command::QUIT
              next # back to login screen
            end
            ui.enter_command_mode Command::QUIT # , Command::FILTER
            cmd = nil
            while cmd.nil?
              ui.display Screen::PlayerList, fibs.active_players
              cmd = ui.available_command
            end
          end
          sleep 10
          break
        end
      end
    end

    def display_welcome(ui)
      ui.display Screen::LOGIN
      ui.enter_command_mode Command::QUIT, Command::LOGIN
      cmd = ui.command(true)
      cmd == Command::LOGIN
    end

    def prompt_credentials(ui)
      ui.enter_text_mode Prompt::USERNAME
      username = ui.text(true)
      return nil if username.nil?
      ui.enter_text_mode Prompt::PASSWORD
      password = ui.text(true)
      [username, password]
    end
  end
end
