require "tanks/version"

module Tanks
  def self.root
    File.dirname __dir__
  end

  def self.media(path)
    File.join(self.root, 'media', path)
  end
end

require "tanks/server"
require "tanks/client"
require "tanks/network"

