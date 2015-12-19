
require 'gosu'
require 'socket'
require 'tanks/keyboard'
require 'tanks/projectile'
require 'tanks/player'

module Tanks
  class Client < Gosu::Window
    attr_reader :keyboard, :network

    def initialize
      super 800, 600
      @network = Network.new(4001 + rand(20))
      @server = Socket.sockaddr_in(4000, 'localhost')

      @network.send_to(@server, {type: :join})

      @font = Gosu::Font.new(40)
      @game_started = false

      loop do
        msg = @network.next_message
        next unless msg

        if "join_confirm" == msg["type"]
          @player = Player.new(msg["id"])
          @players = [@player]

          msg["players"].each do |id|
            @players << Player.new(id)
          end

          break
        end
      end

      puts @players.inspect

      @projectiles = []
      @keyboard = Keyboard.new(
        Gosu::KbSpace,
        Gosu::KbUp,
        Gosu::KbDown,
        Gosu::KbLeft,
        Gosu::KbRight
      )
    end

    def run
      show
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
      handle_network
      handle_keyboard

      @players.each(&:update)
      @projectiles.each(&:update)
    end

    def draw
      if @game_started
        @player.draw
        @projectiles.each(&:draw)
      else
        @players.each.with_index do |p, i|
          @font.draw(p.id, 10, 10 + i * 40, 1)
        end
      end
    end

    def handle_keyboard
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
    end

    def handle_network
      while msg = network.next_message
        if "joined" == msg["type"]
          @players << Player.new(msg["id"])
        end
      end
    end
  end
end
