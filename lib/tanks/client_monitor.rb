
module Tanks
  class ClientMonitor
    PING_INTERVAL = 2 # seconds
    def initialize(server, net, address_map)
      @network = net
      @address_map = address_map
      @last_ping_addresses = {}
      @last_ping = Time.now
      @server = server
    end

    def ping_all
      @address_map.keys.each do |address|
        @network.send_to(address, {
          type: :ping
          })
        @last_ping_addresses[address] = Time.now
      end
    end

    def update
      current_time = Time.now
      if (current_time - @last_ping) >= PING_INTERVAL
        @last_ping = current_time
        ping_all
      end

      @last_ping_addresses.keys.each do |address|
        last_ping_time = @last_ping_addresses[address]

        if last_ping_time && current_time - last_ping_time >= PING_INTERVAL
          @server.handle_dead_client(address)
        else
          @last_ping_addresses[address] = nil
        end
      end
    end

    def pong_from(address)
      current_time = Time.now
      last_ping_time = @last_ping_addresses[address]

      if last_ping_time && current_time - last_ping_time >= PING_INTERVAL
        @server.handle_slow_client(address)
      else
        @last_ping_addresses[address] = nil
      end
    end

  end
end
