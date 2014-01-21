require 'logger' 

module Gaman
  module Logging
    def logger
      Logging.logger
    end


    def self.logger
      @logger ||= Logger.new("logging-#{Thread.current[:name]}.log")
    end
  end
end
