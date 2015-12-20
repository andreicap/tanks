
require 'gosu'

module Tanks
  class Animation
    def initialize(frames, fps)
      @frames = frames
      @fps = fps
      @current_frame = 0
      @delay = (1000 / @fps).to_i
      @working = false
    end

    def start
      @working = true
    end
    
    def stop
      @working = false
    end

    def current_frame
      if @working
        @current_frame += 1 if frame_expired?
        @current_frame %= @frames.size if @current_frame > @frames.size
      end
      @frames[@current_frame % @frames.size]
    end

    def frame_expired?
       now = Gosu.milliseconds
       @last_frame ||= now
       if (now - @last_frame) > @delay
         @last_frame = now
       end
     end
  end
end
