module Gaman
  class Controller
    def initialize ui
      @ui = ui
    end

    def run
      @ui.login
      @ui.close
    end
  end
end

