module Footprint
  class Event
    attr_reader :time_offset_ms, :data
    def initialize(time_offset_ms, data)
      @time_offset_ms = time_offset_ms
      @data = data
    end

    def time_diff(other_event)
      other_event.time_offset_ms - self.time_offset_ms
    end
  end
end
