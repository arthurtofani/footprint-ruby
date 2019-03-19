module Footprint
  class Evaluator
    class << self
      attr_accessor :on_file_added_blocks
      def on_file_added(&block)
        @on_file_added_blocks ||= []
        @on_file_added_blocks << block
      end

      def evaluate_queries(&block)
        @evaluate_queries_blocks ||= []
        @evaluate_queries_blocks << block
      end

      def on_finish(&block)
        @on_finish_blocks ||= []
        @on_finish_blocks << block
      end
    end

    attr_reader :sys, :config
    def initialize(sys, config)
      @config = config
      @sys = sys
    end

  end
end


