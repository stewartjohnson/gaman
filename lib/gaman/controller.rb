require 'gaman/logging'
require 'gaman/fibs'
require 'gaman/console/prompt'
require 'gaman/console/status'
require 'gaman/console/command'
require 'gaman/console/screen'
require 'gaman/console/user_interface'
require 'gaman/console/view/login'
require 'gaman/console/view/welcome'
require 'gaman/console/view/messaging'
require 'gaman/console/view/players'

module Gaman
  # Internal: The main controller class for CLI gaman.
  class Controller
    include Logging

    # rubocop:disable all
    def run

      Gaman::Console::UserInterface.use do |ui|
        # these are inactive by default
        login_display = Gaman::Console::View::Login.new(ui)
        welcome_display = Gaman::Console::View::Welcome.new(ui)
        messaging_display = Gaman::Console::View::Messaging.new(ui)
        players_display = Gaman::Console::View::Players.new(ui)

        loop do
          login_display.activate
          action = login_display.next_action
          break if action.quit?
          username, password = login_display.credentials if action.login?
          login_display.deactivate

          ui.status Status::ATTEMPTING_CONNECTION

          # TODO: throw exceptions when not connected and fibs is used.
          Gaman::Fibs.use(username: username, password: password) do |fibs|

            fibs.register_listener(messaging_display, :messages)
            fibs.register_listener(players_display, :players)

            display = welcome_display
            display.activate
            loop do
              new_display = case active_display.next_action
                            when action.quit? then nil
                            when action.main? then welcome_display
                            when action.messaging? then messaging_display
                            when action.players_list? then players_display
                            end
              display.deactivate
              display = new_display
              display.activate
            end


            if fibs.connected?
              fibs.register_listener(messaging_listener, :messages)
              ui.status Status::CONNECTED_SUCCESSFULLY
              engage_listeners(fibs, ui)
            else
              # TODO: error details inserted
              ui.display Screen::CONNECTION_ERROR, fibs.last_error
              ui.enter_command_mode Command::RETRY, Command::QUIT
              next # back to login screen
            end
          end
          break
        end
      end
    end

    def display_main_screen(fibs, ui)
      ui.enter_command_mode(Command::QUIT,
                            Command::MESSAGING,
                            Command::PLAYER_LIST)
      ui.display Screen::MAIN
      ui.command(true)
    end

    def display_messaging_center(fibs, ui)
    end

    def display_player_list(fibs, ui)
      fibs.on_change(:players) do |f|
        ui.display Screen::PLAYER_LIST, f.active_players
      end
      ui.display Screen::PLAYER_LIST, fibs.active_players
      ui.enter_command_mode Command::QUIT # , Command::FILTER
      ui.command(true)
    end

    def engage_listeners(fibs, ui)
      # update the title whenever the user information changes or there is a
      # change to the players on the system.
      fibs.on_change(:user, :players) do |f, subject|
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
