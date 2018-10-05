require 'footprint/reports/base_report'

module Footprint
  module Reports
    class FileInputReport < BaseReport
      attr_accessor :reports

      def total_time
        self.benchmark.total
      end

      def files
        self.input
      end

      def files_per_second
        files.count/total_time.to_f
      end

      def events_for(file)
        reports[file][:events].output
      end

      def digests_for(file)
        reports[file][:digests]
      end

      def all_events
        files.map{|f| events_for(f)}.reduce(:+)
      end

      def all_digests
        files.map{|f| digests_for(f).output}.reduce(:+)
      end
    end
  end
end
