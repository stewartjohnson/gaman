require 'logger'

module Gaman
  # Internal: implements logging for this codebase.
  module Logging
    def logger
      Logging.logger
    end

    def self.logger
      @logger ||= Logger.new('logging.log')
    end
  end
end
