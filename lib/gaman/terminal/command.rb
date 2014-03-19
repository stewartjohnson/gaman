module Gaman
  # Internal: Defines the different commands that can be offered to the user.
  module Terminal
    module Command
      %w( quit
          messaging
          player_list
          invite
          login
          double
          shout
          message
          ).each_with_index do |name, i|
        const_set(name.upcase, i)
      end

      def self.key(cmd)
        command_name = constants.find { |name| const_get(name) == cmd }
        I18n.t("commands.#{command_name.downcase}.key")
      end

      def self.label(cmd)
        command_name = constants.find { |name| const_get(name) == cmd }
        I18n.t("commands.#{command_name.downcase}.label")
      end

      def self.from_key(char)
        command_name = constants.find do |name|
          I18n.t("commands.#{name.downcase}.key").downcase == char.downcase
        end
        command_name && const_get(command_name)
      end
    end
  end
end
