
require 'gosu'
require 'socket'
require 'tanks/keyboard'
require 'tanks/projectile'
require 'tanks/player'

module Tanks
  class Client < Gosu::Window
    attr_reader :keyboard, :network

    def initialize(server_host)
      super 800, 600
      @network = Network.new(4001 + rand(20))
      @server = Socket.sockaddr_in(4000, server_host)

      send_to_server({type: :join})

      loop do
        msg = @network.next_message
        next unless msg

        if "join_confirm" == msg["type"]
          @player = Player.new(msg["id"], msg["x"], msg["y"], 'up', 0)
          @players = [@player]

          msg["players"].each do |p|
            @players << Player.new(p["id"], p["x"], p["y"], p["orientation"], p["speed"])
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

    def send_to_server(msg)
      network.send_to(@server, msg)
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
        Gosu::KbUp    => :up,
        Gosu::KbDown  => :down,
        Gosu::KbLeft  => :left,
        Gosu::KbRight => :right
      }
    end

    def update
      handle_network
      handle_keyboard

      @players.each(&:update)
      @projectiles.each(&:update)
    end

    def draw
      @players.each(&:draw)
      @projectiles.each(&:draw)
    end

    def handle_keyboard
      keyboard.update

      if keyboard.pressed? Gosu::KbSpace
        @projectiles << @player.shoot
        send_to_server({
          type: :shoot,
          id: @player.id
        })
      end

      arrow_keys.each do |k|
        if keyboard.pressed?(k)
          @player.set_orientation(orientations[k])
          @player.start
          send_to_server({
            id: @player.id,
            type: :start_move,
            orientation: orientations[k]
          })
        end
      end

      if arrow_keys.any? { |k| keyboard.released?(k) }
        @player.stop
        send_to_server({
          id: @player.id,
          type: :stop_move
        })
      end
    end

    def find_player(id)
      @players.find { |p| p.id == id }
    end


    def handle_network
      while msg = network.next_message
        case msg["type"]
        when "joined"
          @players << Player.new(msg["id"], msg["x"], msg["y"], 'up', 0)
        when "started_move"
          p = find_player(msg["id"])
          next if p.id == @player.id
          p.set_orientation(msg["orientation"])
          p.start
        when "stoped_move"
          p = find_player(msg["id"])
          next if p.id == @player.id
          p.stop
        else
        end
      end
    end
  end
end
