require 'gaman/logging'
require 'gaman/fibs'
require 'gaman/terminal/prompt'
require 'gaman/terminal/status'
require 'gaman/terminal/command'
require 'gaman/terminal/screen'
require 'gaman/terminal/user_interface'
require 'gaman/terminal/view/login'
require 'gaman/terminal/view/welcome'
require 'gaman/terminal/view/messaging'
require 'gaman/terminal/view/players'

# Main controller for the terminal client for FIBS (`gaman`). Co-ordinates
# main flow of the application and connection with FIBS -- hands display off
# to the View helper classes and the UI class (using Curses).
class Gaman::Terminal::Controller
  include Gaman::Logging
  include Gaman::Terminal

  # rubocop:disable all
  def run

    UserInterface.use do |ui|
      # these are inactive by default
      login_view = View::Login.new(ui)
      welcome_view = View::Welcome.new(ui)
      messaging_view = View::Messaging.new(ui)
      players_view = View::Players.new(ui)

      logger.debug { 'activating login view' }
      login_view.activate
      logger.debug { 'getting next action from login view' }
      cmd = login_view.next_action
      break if cmd == Command::QUIT
      username, password = login_view.credentials if cmd == Command::LOGIN
      login_view.deactivate

      ui.status Status::ATTEMPTING_CONNECTION

      # TODO: throw exceptions when not connected and fibs is used.
      Gaman::Fibs.use(username: username, password: password) do |fibs|
        logger.debug { 'registering listeners' }
        fibs.register_listener(messaging_view, :messages)
        # fibs.register_listener(players_view, :players)

        logger.debug { 'starting views' }
        view = welcome_view
        view.activate

        loop do
          new_view = case view.next_action
                        when action.quit? then nil
                        when action.main? then welcome_view
                        when action.messaging? then messaging_view
                        when action.players_list? then players_view
                        end
          view.deactivate
          view = new_view
          view.activate
        end
      end
    end
  end
end
