require 'logger'

module Gaman
  # @api private
  module Logging
    def logger
      Logging.logger
    end

    def self.logger
      @logger ||= Logger.new('logging.log')
    end
  end
end
