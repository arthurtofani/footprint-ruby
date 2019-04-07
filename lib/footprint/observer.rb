module Footprint
  module Observer

    def self.included base
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      def receive_notification(event)
        observers = self.class.callback_blocks[event.name]
        return if observers.nil?
        observers.each{|s| s.call(self, event)}
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


