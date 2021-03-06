module Footprint
  class EventList < Array

    include Concerns::TimeMeasured

    attr_accessor :file_path

    def neighbors_in_time_window_for(event, min_time_ms, max_time_ms)
      self.select do |s|
        s!=event &&
        s.time_offset_ms > (event.time_offset_ms + min_time_ms) &&
        s.time_offset_ms < (event.time_offset_ms + max_time_ms)
      end
    end

    def next(event, _match_conditions=nil)
      self.select do |s|
        s.time_offset_ms > event.time_offset_ms
      end.first
    end

  end
end
