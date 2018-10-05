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

      def scoring(&block)
        @@scoring = block
      end

    end

    attr_reader :database, :config
    def initialize(config)
      @config = config
      @database = Client.new(config[:database_url])
    end


    # add digests to the database based on a list of file_paths
    # returns a report object
    def add_files(file_path_list)
      files = File.open(file_path_list).read.split("\n")
      reports = {}
      Reports::FileInputReport.generate(files) do
        ct_files = files.count
        files.each_with_index do |file_path, idx|
          event_report = generate_events(file_path)
          digest_report = collect_digests(event_report)
          metadata = extract_metadata(file_path)
          database.add_media(file_path, metadata, digest_report.output)
          puts "File added: #{file_path} - #{(idx/ct_files.to_f)}"
          reports[file_path] = {events: event_report, digests: digest_report, metadata: metadata}
        end
      end.tap{|s| s.reports = reports }
    end

    def run_queries(query_path_list)
      queries = []
      File.open(query_path_list).read.split("\n").each do |file|
        queries << query(file)
      end
      queries
    end

    def query(query_path, threshold=nil)
      report = nil
      Reports::QueryReport.generate(query_path) do
        event_report = generate_events(query_path)
        digest_report = collect_digests(event_report)
        db_result = database.query(digest_report.output, threshold)
        report = {events: event_report, digests: digest_report}
        r = run_scoring(db_result)
      end.tap{|s| s.report = report}
    end

    def generate_events(file_path)
      Reports::EventGenerationReport.generate(file_path) do
        self.run_generate_events(file_path)
      end
    end

    def collect_digests(event_report)
      events = event_report.output
      Reports::DigestGenerationReport.generate(events) do
        self.run_generate_digests(events)
      end.tap{|s| s.event_report = event_report }
    end

    # Each block shall return an Event array
    # The method retuns an array with all events collected
    def run_generate_events(file_path)
      event_list = []
      @@generate_events_strategies.each do |gen_event_strategy_block|
        event_list += gen_event_strategy_block.call(file_path, self)
      end
      EventList.new(event_list)
    end

    # Each block shall return a Digest array
    # The method retuns an array with all digests collected
    def run_generate_digests(event_list)
      digest_list = []
      @@generate_digests_strategies.each do |gen_digest_strategy_block|
        digest_list += gen_digest_strategy_block.call(EventList.new(event_list), self)
      end
      DigestList.new(digest_list)
    end

    def run_scoring(digest_list)
      r = digest_list.keys.map do |key|
        [key, @@scoring.call(key, digest_list)]
      end
      r.sort{|a, b| b[1]<=>a[1]}
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
