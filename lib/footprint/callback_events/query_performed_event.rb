module Footprint
  module CallbackEvents
    class QueryPerformedEvent < Event

      attr_accessor :file_path, :score, :events, :digests, :db_results
      attr_accessor :query_time_start, :query_time_end
      attr_accessor :scoring_time_start, :scoring_time_end

      def initialize(file_path, score, events, digests, db_results)
        self.file_path = file_path
        self.score = score
        self.events = events
        self.digests = digests
        self.db_results = db_results
      end

      def digests_time_spent_ms
        self.digests.time_spent_ms
      end

      def events_time_spent_ms
        self.events.time_spent_ms
      end

      def scoring_time_spent_ms
        ((scoring_time_end - scoring_time_start) * 1000) rescue nil
      end

      def query_time_spent_ms
        ((query_time_end - query_time_start) * 1000) rescue nil
      end

    end
  end
end
