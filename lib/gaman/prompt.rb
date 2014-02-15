module Gaman
  module Prompt
    # defines the different prompts that can be offered to the user.
    %w( username
        password
        ).each_with_index do |prompt,i|
      const_set(prompt.capitalize, i)
    end

    def self.text id
      name = constants.find{ |name| const_get(name)==id }
      I18n.t("prompts.#{name.downcase}")
    end
  end
end