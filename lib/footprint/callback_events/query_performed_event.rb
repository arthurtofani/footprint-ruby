module Footprint
  module CallbackEvents
      class QueryPerformedEvent < Event
        attr_accessor :file_path, :result, :expectation

        def initialize(file_path, result, expectation)
          self.file_path, self.result, self.expectation = file_path, result, expectation
        end
      end
  end
end
