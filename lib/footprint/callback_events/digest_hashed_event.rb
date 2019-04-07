module Footprint
  module CallbackEvents
    class DigestHashedEvent < Event
      attr_reader :digest, :previous_value

      def initialize(digest, previous_value)
        @digest, @previous_value = digest, previous_value
      end
    end
  end
end
