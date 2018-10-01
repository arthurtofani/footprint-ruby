require 'taglib'
require 'pry'

module Footprint
  class System

    class << self
      def generate_events(&block)
        @@generate_events_strategies ||= []
        @@generate_events_strategies << block
      end

      def generate_digests(&block)
        @@generate_digests_strategies ||= []
        @@generate_digests_strategies << block
      end

      def alignment(&block)
        @@alignment = block
      end

      # Each block shall return an Event array
      # The method retuns an array with all events collected
      def run_generate_events(file_path)
        event_list = []
        @@generate_events_strategies.each do |gen_event_strategy_block|
          event_list += gen_event_strategy_block.call(file_path)
        end
        EventList.new(event_list)
      end

      # Each block shall return a Digest array
      # The method retuns an array with all digests collected
      def run_generate_digests(event_list)
        digest_list = []
        @@generate_digests_strategies.each do |gen_digest_strategy_block|
          digest_list += gen_digest_strategy_block.call(event_list)
        end
        DigestList.new(digest_list)
      end
    end

    attr_reader :database, :reports
    def initialize(config)
      @database = Client.new(config[:database_url])
    end


    # add digests to the database based on a list of file_paths
    # returns a report object
    def add_files(file_path_list)
      files = File.open(file_path_list).read.split("\n")
      @reports = {}
      Reports::FileInputReport.generate(files) do
        files.each do |file_path|
          event_report = generate_events(file_path)
          digest_report = collect_digests(event_report.output)
          metadata = extract_metadata(file_path)
          database.add_media(file_path, metadata, digest_report.output)
          @reports[file_path] = {events: event_report, digest: digest_report, metadata: metadata}
        end
      end
    end


    def query(query_path)
      Reports::QueryReport.generate(query_path) do
        event_report = generate_events(query_path)
        digest_report = collect_digests(event_report.output)
        database.query(digest_report.output)
      end
    end

    def generate_events(file_path)
      Reports::EventGenerationReport.generate(file_path) do
        self.class.run_generate_events(file_path)
      end
    end

    def collect_digests(events)
      Reports::DigestGenerationReport.generate(events) do
        self.class.run_generate_digests(events)
      end
    end

    def extract_metadata(file_path)
      metadata = {}
      TagLib::FileRef.open(file_path) do |fileref|
        unless fileref.null?
          tag = fileref.tag
          properties = fileref.audio_properties

          metadata[:artist] = tag.artist
          metadata[:album] = tag.album
          metadata[:length] = properties.length
        end
      end
      metadata
    end

  end
end
