require 'footprint/reports/base_report'

module Footprint
  module Reports
    attr_reader :rows
    class FileInputReport < BaseReport

    end

    class FileInputReportRow
      attr_reader :input_file, :events, :digests
    end
  end
end
