
require 'tanks/network'

module Tanks
  class Server
    attr_reader :players, :network

    def initialize
      @network = Network.new
    end

    def run
      previous = Time.now
      lag = 0.0
      loop do
        current = Time.now
        elapsed = current - previous
        previous = current
        lag += elapsed

        processInput
        network.dispatch_messages

        while lag >= MS_PER_UPDATE
          update
          lag -= MS_PER_UPDATE
        end

        render
      end
      loop do

      end
    end

    def player_joined(id)
      puts id
    end

    def shutdown
      network.shutdown
    end

  end

end
