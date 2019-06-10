module Footprint
  module Concerns
    module TimeMeasured
      attr_accessor :time_start, :time_end

      def cron_start!
        @time_start = Time.now
        self
      end

      def cron_end!
        @time_end = Time.now
        self
      end

      def time_spent_ms
        ((@time_end - @time_start)*1000) rescue nil
      end
    end
  end
end
