require 'gaman/terminal/command'

class Gaman::Terminal::View::Welcome
  def initialize(ui)
    @ui = ui
    @username = @password = nil
  end

  def activate
    @ui.dialog text:   I18n.t(:main_text),
               width:  60,
               height: 10
    @ui.status Gaman::Terminal::Status::CHOOSE_COMMAND
  end

  def next_action
    sleep 20
    Command::QUIT
  end

  def deactivate
    # nop
  end
end
