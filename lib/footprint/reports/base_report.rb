require 'benchmark'

module Footprint
  module Reports
    class BaseReport
      class << self
        def generate(input, &block)
          output = nil
          benchmark = Benchmark.measure do
            output = yield
          end
          new(input, output, benchmark)
        end
      end

      attr_accessor :input, :output, :benchmark
      def initialize(input, output, benchmark)
        self.input = input
        self.output = output
        self.benchmark = benchmark
      end
    end
  end
end
