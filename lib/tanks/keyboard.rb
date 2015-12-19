
require 'gosu'

module Tanks
  class Keyboard
    attr_reader :states
    def initialize(*args)
      default = {now: false, before: false}
      @states = Hash.new(default)
      args.each { |k| @states[k] = default.dup }

      puts @states.inspect
    end

    def update
      states.keys.each do |k|
        states[k][:before] = states[k][:now]
        states[k][:now] = Gosu::button_down?(k)
      end
    end

    def pressed?(k)
      states[k][:now] && !states[k][:before]
    end

    def released?(k)
      states[k][:before] && !states[k][:now]
    end

    def down?(k)
      states[k][:now]
    end
  end
end
