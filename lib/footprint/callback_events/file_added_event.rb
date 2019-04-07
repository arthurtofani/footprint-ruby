module Footprint
  module CallbackEvents
    class FileAddedEvent < Event
      attr_accessor :filename, :events, :digests

      def initialize(filename, events, digests)
        self.filename, self.events, self.digests = filename, events, digests
      end
    end
  end
end
