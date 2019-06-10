require 'taglib'
require 'securerandom'

module Footprint
  class AudioSlicer
    attr_reader :time_offset
    attr_accessor :digest
    def initialize(sys, filelist_path, slices=1, seconds=2)
      @sys = sys
      @slices = slices.to_i
      @seconds = seconds.to_i
      @filelist = File.open(filelist_path).read.split("\n")
    end

    def run
      file_list = []
      expected = []
      output_folder = @sys.config.query_folder
      complete_output_folder = "#{output_folder}/#{@seconds.to_s}"
      `mkdir -p #{complete_output_folder}`
      @filelist.each do |input_file_path|
        @slices.times do |t|
          total_time_seconds = get_duration(input_file_path) || 30 # TODO: remove it
          from_seconds = rand(0.to_f..(total_time_seconds - @seconds))
          to_seconds = from_seconds + @seconds
          #ext = input_file_path.split('/').last.split(".").last
          ext = "wav"
          new_file_path = "#{complete_output_folder}/#{SecureRandom.hex(8)}.#{ext}"
          slice_audio(input_file_path, from_seconds, to_seconds, new_file_path)
          file_list << new_file_path
          expected << input_file_path
        end
      end
      File.open("#{complete_output_folder}/queries.txt", 'w'){|f| f.write file_list.join("\n")}
      File.open("#{complete_output_folder}/expected.txt", 'w'){|f| f.write expected.join("\n")}
    end

    def get_duration(file)
      l = nil
      TagLib::FileRef.open(file) do |fileref|
        unless fileref.null?
          tag = fileref.tag
          properties = fileref.audio_properties
          l = properties.length
        end
      end
      l
    end

    def notify_query_created(file_path, start_point, seconds)
      @sys.notify_observers(CallbackEvents::QueryCreatedEvent.new(file_list, slices, seconds))
    end

    def slice_audio(input_file_path, from_seconds, to_seconds, output_file_path)
      `ffmpeg -i #{input_file_path} -ss #{from_seconds} -to #{to_seconds} -c copy #{output_file_path}`
    end
  end
end
