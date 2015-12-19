
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

    end

    def render

    end

    def handle_network
      while msg = network.next_message
        puts msg.inspect
        case msg["type"]
        when "join"
          add_player(msg["from"])
        else
        end
      end
    end

    def add_player(addr_info)
      id = next_id
      player = Player.new(id)

      @address_map.keys.each do |addr|
        network.send_to(addr, {
          type: :joined,
          id: id
        })
      end

      network.send_to(addr_info, {
        type: :join_confirm,
        id: id,
        players: @players.map(&:id)
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
