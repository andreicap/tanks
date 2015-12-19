
require 'gosu'

module Tanks
  class Projectile
    attr_reader :owner

    def initialize(x, y, vx, vy, owner)
      @x, @y, @vx, @vy = x, y, vx, vy
      @owner = owner
    end

    def update
      @x += @vx
      @y += @vy
    end

    def draw
      Gosu::draw_rect(@x, @y, 3, 3, Gosu::Color::WHITE)
    end
  end
end
