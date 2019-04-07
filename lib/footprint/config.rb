require 'pry'
require 'json'

module Footprint
  class Config
    def self.load(file_path)
      new.load_file(file_path)
    end

    attr_accessor :file_path
    def initialize
    end

    def load_file(file_path)
      self.file_path = file_path
      (@json = JSON.parse(File.open(self.file_path).read)) rescue raise 'File not found'
      @json.keys.each do |arg|
        unless self.methods.include?(arg)
          self.class.send(:define_method, arg) do |&block|
            @json[arg]
          end
        end
      end
      return self
    end

    def init!
      method_object = method_class.new(self)
      ev_obj = evaluator_class.new(method_object)
      method_object.add_observer ev_obj
      method_object.evaluator = ev_obj
      method_object
    end

    def method_class
      Object.const_get(self.method_name)
    end

    def evaluator_class
      Object.const_get(self.evaluator)
    end

  end
end
