module Gaman
  module Terminal
    # Internal: defines the constants used to identify different prompts
    # that are displayed to the user.
    module Prompt
      # defines the different prompts that can be offered to the user.
      %w( username
          password
          ).each_with_index do |prompt, i|
        const_set(prompt.upcase, i)
      end

      def self.text(id)
        name = constants.find { |n| const_get(n) == id }
        I18n.t("prompts.#{name.downcase}")
      end
    end
  end
end
