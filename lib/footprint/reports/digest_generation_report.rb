require 'footprint/reports/base_report'

# Handles info related to the digest generation phase
module Footprint
  module Reports
    class DigestGenerationReport < BaseReport
      attr_accessor :event_report
    end
  end
end
