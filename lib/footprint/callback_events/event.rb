module Footprint
  module CallbackEvents
    class Event
      def name
        self.class.name.split('::').last.to_s[0..-6].underscore

      end
    end
  end
end
