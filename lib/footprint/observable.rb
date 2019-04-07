module Footprint
  module Observable

    def self.included base
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      def add_observer(observer)
        @observers ||= []
        @observers << observer
      end

      def notify_observers(event)
        @observers ||= []
        @observers.each do |observer|
          observer.receive_notification(event)
        end
      end
    end

    module ClassMethods
      attr_accessor :callback_blocks

      def add_callback(callback_name, block)
        return false if block.nil?
        @callback_blocks ||= {}
        @callback_blocks[callback_name.to_s] ||= []
        @callback_blocks[callback_name.to_s] << block
        true
      end

      Footprint::CallbackEvents.constants.each do |callback_class_name|
        cbk_name = callback_class_name.to_s[0..-6].underscore
        define_method "on_#{cbk_name}" do |&block|
          add_callback(cbk_name, block)
        end
      end

    end
  end
end


