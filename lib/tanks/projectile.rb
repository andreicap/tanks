
require 'gosu'

module Tanks
  class Projectile
    attr_reader :owner, :size, :x, :y

    def initialize(x, y, vx, vy, owner)
      @x, @y, @vx, @vy = x, y, vx, vy
      @size = 5
      @owner = owner
    end

    def update
      @x += @vx
      @y += @vy
    end

    def draw
      Gosu::draw_rect(@x-@size/2, @y-@size/2, @size, @size, Gosu::Color::WHITE)
    end
  end
end
