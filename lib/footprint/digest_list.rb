module Footprint
  class DigestList < Array
    def db_format
      map{|s| "#{s.digest.tr(':', '#')}:#{s.time_offset.to_i}"}
    end
  end
end
