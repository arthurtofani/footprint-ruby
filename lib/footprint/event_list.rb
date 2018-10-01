module Footprint
  class EventList < Array
    def neighbors_in_time_window_for(event, min_time_ms, max_time_ms)
      self.select do |s|
        s!=event &&
        s.time_offset_ms > (event.time_offset_ms + min_time_ms) &&
        s.time_offset_ms < (event.time_offset_ms + max_time_ms)
      end
    end
  end
end
