require 'gaman/terminal/command'

module Gaman::Terminal::View
  class Welcome
    def initialize(ui)
      @ui = ui
      @username = @password = nil
    end

    def activate
    end

    def next_action
    end

    def deactivate
      # nop
    end
  end
end
