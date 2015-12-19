
require 'gosu'

module Tanks
  class Player
    def initialize
      @image = Gosu::Image.new(Tanks.media("starfighter.bmp"))
      @x = 400
      @y = 300
      @ox = 0
      @oy = -1
      @speed = 0
    end

    def update
      @x += @ox * @speed
      @y += @oy * @speed
    end

    def start
      @speed = 1
    end

    def stop
      @speed = 0
    end

    def orient_up
      @ox, @oy = 0, -1
    end

    def orient_down
      @ox, @oy = 0, 1
    end

    def orient_left
      @ox, @oy = -1, 0
    end

    def orient_right
      @ox, @oy = 1, 0
    end

    def shoot
      Projectile.new(@x, @y, @ox * 5, @oy * 5)
    end

    def draw
      @image.draw_rot(@x, @y, 1, Gosu::angle(0, 0, @ox, @oy))
    end
  end
end
