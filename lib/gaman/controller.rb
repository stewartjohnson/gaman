require 'gaman/logging'
require 'gaman/prompt'
require 'gaman/command'
require 'gaman/console_user_interface'

module Gaman
  class Controller

    include Logging

    def run

      logger.debug { "controller: gaman controller starting" }
      Gaman::ConsoleUserInterface.use do |ui|
        loop do
          ui.display Screen::Login
          ui.set_commands Command::Quit, Command::Login
          cmd = ui.get_command(true)
          break if cmd == Command::Quit
          ui.set_prompt Prompt::Username
          username = ui.get_text(true)
          ui.set_prompt Prompt::Password
          password = ui.get_text(true)
          logger.debug { "received credentials: #{username}/#{password}"}


          # ui.status Status::AttemptingConnection
          # Fibs.use(:username => username, :password => password) do |fibs|
          #   if fibs.connected?
          #     ui.status Status::ConnectedSuccessfully
          #   else
          #     ui.display Screen::ConnectionError # TODO error details
          #     next # back to login screen
          #   end
          #   ui.commands Command::Quit, Command::Filter, Command::Invite, Command::Resume
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
          # end
          sleep 10
          break
        end
      end
    end

  end
end

