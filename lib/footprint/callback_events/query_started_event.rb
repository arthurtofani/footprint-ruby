module Footprint
  module CallbackEvents
    class QueryStartedEvent < Event
      attr_accessor :filename

      def initialize(filename)
        self.filename = filename
      end
    end
  end
end
