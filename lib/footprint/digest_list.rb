module Footprint
  class DigestList < Array
    include Concerns::TimeMeasured

    def db_format
      map{|s| "#{s.digest.tr(':', '#')}:#{s.time_offset.to_i}"}
    end
  end
end
