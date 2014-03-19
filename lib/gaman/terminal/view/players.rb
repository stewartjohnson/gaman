require 'gaman/terminal/command'

module Gaman::Terminal::View
  class Players
    def initialize(ui)
      @ui = ui
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
