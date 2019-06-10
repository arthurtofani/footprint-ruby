module Footprint
  module CallbackEvents
    class QueryCreatedEvent < Event
      attr_accessor :file_path, :start_point, :seconds

      def initialize(file_path, start_point, seconds)
        self.file_path = file_path
        self.start_point = start_point
        self.seconds = seconds
      end
    end
  end
end
