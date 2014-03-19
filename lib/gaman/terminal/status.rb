module Gaman
  module Terminal
    # Internal: defines the constants used to identify different statuses that
    # are displayed to the user.
    module Status
      %w( attempting_connection
          connected_successfully
          ).each_with_index do |status, i|
        const_set(status.upcase, i)
      end

      def self.text(id)
        name = constants.find { |n| const_get(n) == id }
        I18n.t("statuses.#{name.downcase}")
      end
    end
  end
end
