
require 'gosu'

module Tanks
  class Player
    attr_reader :id, :x, :y, :speed

    def initialize(id, x, y, orientation, speed)
      @id = id
      @image = Gosu::Image.new(Tanks.media("starfighter.bmp"))
      @x = x
      @y = y
      set_orientation(orientation)
      @speed = speed
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

    def set_orientation(orientation)
      public_send("orient_#{orientation}")
    end

    def set_position(x, y)
      @x, @y = x, y
    end

    def get_orientation
      if 0 == @ox
        if @oy > 0
          'down'
        else
          'up'
        end
      else
        if @ox > 0
          'right'
        else
          'left'
        end
      end
    end

    def shoot
      Projectile.new(@x, @y, @ox * 5, @oy * 5, self)
    end

    def draw
      @image.draw_rot(@x, @y, 1, Gosu::angle(0, 0, @ox, @oy))
    end
  end
end
