module Gaman
  module Listener
    class Messaging
      def initialize(ui)
        @ui = ui
        @enabled = false # off be default
      end

      def enable
        @enabled = true
      end

      def disable
        @enabled = false
      end

      # Internal: called by Fibs whenever a messageing change has happened.
      def receive(fibs, subject)
        # TODO: update the internal messaging state with the messaging data
        # that changed. Implementation decision is then what to pass to the UI
        # -- I expect this object will be enabled/disabled by the master
        # controller, and when enabled it will send messaging data to the UI
        # for display.
        fail NotImplementedError, "not ready to receive messages in the consol yet!"
      end
    end
  end
end
