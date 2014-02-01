require 'gaman/logging'
require 'gaman/prompt'
require 'gaman/command'
require 'gaman/console_user_interface'

module Gaman
  class Controller

    include Logging

    def run

      Gaman::ConsoleUserInterface.use do |ui|
        loop do
          ui.display Screen::Login
          ui.commands Command::Quit, Command::Login
          cmd = ui.wait_for_command
          break if cmd == Command::Quit

          # username = ui.prompt Prompt::Username
          # password = ui.prompt Prompt::Password
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

