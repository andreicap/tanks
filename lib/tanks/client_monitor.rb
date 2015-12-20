
module Tanks
  class ClientMonitor
    PING_INTERVAL = 2 # seconds
    def initialize(net, players, address_map)
      @network = net
      @players = players
      @address_map = address_map
      @last_ping = Time.now
    end

    def update

    end
  end
end
