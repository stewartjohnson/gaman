module Gaman

  module ConsoleMode
    %w( none command text ).each_with_index do |mode,i|
      const_set(mode.capitalize, i)
    end
  end

end