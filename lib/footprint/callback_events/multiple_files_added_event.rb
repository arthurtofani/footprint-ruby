module Footprint
  module CallbackEvents
    class MultipleFilesAddedEvent < Event
      attr_accessor :file_list_path, :file_added_events

      def initialize(file_list_path, file_added_events)
        self.file_list_path, self.file_added_events = file_list_path, file_added_events
      end
    end
  end
end
