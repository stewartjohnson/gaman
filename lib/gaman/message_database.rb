require 'gaman/message'
require 'gaman/logging'

module Gaman
  # Internal: Holds the database of messages for CRUD operations (in memory).
  class MessageDatabase
    include Logging

    def messages
      @messages ||= []
    end

    def add(options)
      logger.debug { "Creating message: #{options.inspect}" }
      messages << Gaman::Message.new(options)
    end

    # Internal: returns a list of messages that match the supplied options.
    # TODO: currently only supports the :type option.
    def list(options)
      messages.select do |m|
        m.type == options[:type] if options[:type]
      end
    end
  end
end
