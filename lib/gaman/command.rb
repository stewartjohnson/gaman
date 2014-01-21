module Gaman

  class Command
    attr_accessor :key, :value, :label
    
    def initialize key, value, label
      @key = key
      @value = value
      @label = label
    end

    def to_s
      @value.to_s
    end
  end

end