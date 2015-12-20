
require 'tanks/network'
require 'tanks/player'
require 'tanks/client_monitor'

module Tanks
  class Server
    MS_PER_UPDATE = 16.667
    attr_reader :players, :network

    def initialize
      @network = Network.new
      @players = []
      @address_map = {}
      @projectiles = []
      @client_monitor = ClientMonitor.new(self, @network, @address_map)
    end

    def run
      previous = Time.now
      lag = 0.0
      loop do
        current = Time.now
        elapsed = (current - previous) * 1000
        previous = current
        lag += elapsed

        handle_network

        while lag >= MS_PER_UPDATE
          update
          lag -= MS_PER_UPDATE
        end
      end
    end

    def update
      @players.each(&:update)
      @client_monitor.update
      @projectiles.each(&:update)
      handle_collisions
    end

    def handle_collisions
      hits = []
      @players.each do |p|
        @projectiles.each do |proj|
          unless proj.owner == p
            hits << [p, proj] if intersects?(proj, p)
          end
        end
      end

      hits.each do |p, proj|
        respawn_player(p)
        @projectiles.delete(proj)
      end
    end

    def respawn_player(p)
      p.set_position(rand(600), rand(400))
      network.broadcast_to(@address_map.keys, {
        type: :respawn,
        id: p.id,
        x: p.x,
        y: p.y
      })
    end

    def intersects?(obj_1, obj_2)
      dist_square = (obj_2.x - obj_1.x) ** 2 + (obj_2.y - obj_1.y) ** 2
      coll_dist_square = (obj_1.size + obj_2.size) ** 2
      dist_square < coll_dist_square
    end

    def handle_network
      while msg = network.next_message
        puts msg.inspect

        if "join" == msg["type"]
          add_player(msg["from"])
        elsif "pong" == msg["type"]
          @client_monitor.pong_from(msg["from"])
        end

        if player = find_player_by_addr(msg["from"])
          send(msg["type"], player, msg) if respond_to?(msg["type"])
        end
      end
    end

    def find_player(id)
      @players.find { |p| p.id == id }
    end

    def find_player_by_addr(addr)
      find_player(@address_map[addr])
    end

    def start_move(p, msg)
      p.set_orientation(msg["orientation"])
      p.start
      puts "#{p.x} #{p.y}"
      network.broadcast_to(@address_map.keys, {
        type: :started_move,
        id: p.id,
        x: p.x,
        y: p.y,
        orientation: p.get_orientation
      })
    end

    def stop_move(p, msg)
      p.stop
      network.broadcast_to(@address_map.keys, {
        type: :stoped_move,
        id: p.id#,
        # x: p.x,
        # y: p.y
      })
    end

    def shoot(p, msg)
      @projectiles << p.shoot
      network.broadcast_to(@address_map.keys, {
        type: :has_shot,
        id: p.id#,
        # x: p.x,
        # y: p.y
      })
    end

    def add_player(addr_info)
      id = next_id
      x = rand(600)
      y = rand(400)
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

    def handle_dead_client(address)
      puts "Dead client: #{address.ip_address}"
    end

    def handle_slow_client(address)
      puts "Slow client: #{address.ip_address}"
    end

  end
end
