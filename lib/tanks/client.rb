
require 'gosu'
require 'tanks/keyboard'
require 'tanks/projectile'
require 'tanks/player'

module Tanks
  class Client < Gosu::Window
    attr_reader :keyboard

    def initialize
      super 800, 600
      @player = Player.new
      @projectiles = []
      @keyboard = Keyboard.new(
        Gosu::KbSpace,
        Gosu::KbUp,
        Gosu::KbDown,
        Gosu::KbLeft,
        Gosu::KbRight
      )
    end

    def arrow_keys
      [
        Gosu::KbUp,
        Gosu::KbDown,
        Gosu::KbLeft,
        Gosu::KbRight
      ]
    end

    def orientations
      {
        Gosu::KbUp    => :orient_up,
        Gosu::KbDown  => :orient_down,
        Gosu::KbLeft  => :orient_left,
        Gosu::KbRight => :orient_right
      }
    end

    def update
      keyboard.update

      if keyboard.pressed? Gosu::KbSpace
        @projectiles << @player.shoot
      end

      arrow_keys.each do |k|
        if keyboard.pressed?(k)
          @player.public_send(orientations[k])
          @player.start
        end
      end

      @player.stop unless arrow_keys.any? { |k| keyboard.down?(k) }

      @player.update
      @projectiles.each(&:update)
    end

    def draw
      @player.draw
      @projectiles.each(&:draw)
    end

  end
end
