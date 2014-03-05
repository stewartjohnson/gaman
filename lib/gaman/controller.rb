require 'gaman/logging'
require 'gaman/prompt'
require 'gaman/status'
require 'gaman/command'
require 'gaman/screen'
require 'gaman/console_user_interface'
require 'gaman/fibs'

module Gaman
  # Internal: The main controller class for CLI gaman.
  class Controller
    include Logging

    def run
      logger.debug { 'running' }
      Gaman::ConsoleUserInterface.use do |ui|
        loop do
          break unless display_welcome(ui)
          username, password = prompt_credentials(ui)
          next if username.nil? || password.nil?

          ui.status Status::ATTEMPTING_CONNECTION
          Gaman::Fibs.use(username: username, password: password) do |fibs|
            if fibs.connected?
              ui.status Status::CONNECTED_SUCCESSFULLY
              engage_listeners(fibs, ui)
            else
              # TODO: error details inserted
              ui.display Screen::CONNECTION_ERROR, fibs.last_error
              ui.enter_command_mode Command::RETRY, Command::QUIT
              next # back to login screen
            end
            display_player_list(fibs, ui)
          end
          break
        end
      end
    end

    def display_player_list(fibs, ui)
      fibs.on_change(:players) do |f|
        logger.debug { 'block called to update player list' }
        ui.display Screen::PLAYER_LIST, f.active_players
      end
      ui.display Screen::PLAYER_LIST, fibs.active_players
      ui.enter_command_mode Command::QUIT # , Command::FILTER
      ui.command(true)
    end

    def engage_listeners(fibs, ui)
      # update the title whenever the user information changes or there is a
      # change to the players on the system.
      fibs.on_change(:user, :players) do |f|
        ui.title "#{f.username} " +
          "[#{f.active_players.count}] " +
          "Rating: #{f.user(:rating)} " +
          "Experience: #{f.user(:experience)}"
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
