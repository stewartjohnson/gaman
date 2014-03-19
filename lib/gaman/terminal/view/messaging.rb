require 'gaman/logging'

module Gaman::Terminal::View
  class Messaging
    include Gaman::Logging

    def initialize(ui)
      @ui = ui
      @enabled = false # off by default
    end

    def activate
      @enabled = true
    end

    def deactivate
      @enabled = false
    end

    def next_action
    end

    def receive(subject, message)
      logger.debug { "received a #{message.type} from #{message.from}: #{message.text}" }
    end
  end
end
