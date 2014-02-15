module Gaman
  module Command
    # defines the different commands that can be offered to the user.
    %w( quit 
        invite 
        login 
        double 
        shout 
        message 
        ).each_with_index do |name, i|
      const_set(name.capitalize, i)
    end

    def self.key cmd
      command_name = constants.find{ |name| const_get(name)==cmd }
      I18n.t("commands.#{command_name.downcase}.key")
    end

    def self.label cmd
      command_name = constants.find{ |name| const_get(name)==cmd }
      I18n.t("commands.#{command_name.downcase}.label")
    end

    def self.from_key char
      command_name = constants.find { |name| I18n.t("commands.#{name.downcase}.key").downcase==char.downcase }
      command_name && const_get(command_name) 
    end
  end
end