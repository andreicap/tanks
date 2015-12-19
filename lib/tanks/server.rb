
require 'tanks/network'
require 'tanks/player'

module Tanks
  class Server
    MS_PER_UPDATE = 16.667
    attr_reader :players, :network

    def initialize
      @network = Network.new
      @players = []
      @address_map = {}
      @projectiles = []
    end

    def run
      previous = Time.now
      lag = 0.0
      loop do
        current = Time.now
        elapsed = current - previous
        previous = current
        lag += elapsed

        handle_network
        #puts players.map(&:id).inspect

        while lag >= MS_PER_UPDATE
          update
          lag -= MS_PER_UPDATE
        end

        render
      end
    end

    def update
      @players.each(&:update)
    end

    def render

    end

    def handle_network
      while msg = network.next_message
        puts msg.inspect
        case msg["type"]
        when "join"
          add_player(msg["from"])
        when "start_move"
          p = find_player(msg["id"])
          next unless p
          p.set_orientation(msg["orientation"])
          p.start
          network.broadcast_to(@address_map.keys, {
            id: p.id,
            type: :started_move,
            orientation: p.get_orientation
          })
        when "stop_move"
          p = find_player(msg["id"])
          next unless p
          p.stop
          network.broadcast_to(@address_map.keys, {
            id: p.id,
            type: :stoped_move
          })
        else
        end
      end
    end

    def find_player(id)
      @players.find { |p| p.id == id }
    end

    def add_player(addr_info)
      id = next_id
      x = rand(800)
      y = rand(600)
      player = Player.new(id, x, y, 'up', 0)

      @address_map.keys.each do |addr|
        network.send_to(addr, {
          type: :joined,
          id: id,
          x: x,
          y: y
        })
      end

      network.send_to(addr_info, {
        type: :join_confirm,
        id: id,
        x: x,
        y: y,
        players: @players.map { |p|
          {
            id: p.id,
            x: p.x,
            y: p.y,
            orientation: p.get_orientation,
            speed: p.speed
          }
        }
      })

      @players << player
      @address_map[addr_info] = id
    end

    def next_id
      @next_id ||= 0
      @next_id += 1
    end

    def shutdown
      network.shutdown
    end

  end
end
