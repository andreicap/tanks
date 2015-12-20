
require 'json'
require 'socket'

module Tanks
  class Network
    attr_reader :clients, :datagram_buffer

    def initialize(port = 4000)
      @udp_socket = UDPSocket.new(Socket::AF_INET)
      @udp_socket.bind('0.0.0.0', port)
      @datagram_buffer = []

      @listener = Thread.new do
        loop do
          @datagram_buffer << @udp_socket.recvfrom(1024)
        end
      end
    end


    def shutdown
      @listener.kill
    end

    def has_messages?
      !datagram_buffer.empty?
    end

    def next_message
      return nil if datagram_buffer.empty?
      str, info = datagram_buffer.shift
      m = JSON.parse(str)
      m["from"] = Addrinfo.new(info)
      m
    rescue JSON::ParserError
      nil
    end

    def get_messages
      msgs = datagram_buffer.map do |str, info|
        m = JSON.parse(str)
        m["from"] = info
        m
      end
      datagram_buffer.clear
      msgs
    end

    def broadcast_to(addresses, event)
      addresses.each { |addr| send_to(addr, event) }
    end

    def send_to(address, event)
      @udp_socket.send(JSON.generate(event), 0, address)
    end
  end
end
