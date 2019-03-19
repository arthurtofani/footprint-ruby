require 'taglib'
require 'pry'

module Footprint
  class System

    class << self
      attr_accessor :generate_events_strategies, :generate_digests_strategies, :scoring_var

      def generate_events(&block)
        @generate_events_strategies ||= []
        @generate_events_strategies << block
      end

      def generate_digests(&block)
        @generate_digests_strategies ||= []
        @generate_digests_strategies << block
      end

      def scoring(&block)
        @scoring_var = block
      end

    end

    attr_reader :database, :config
    attr_accessor :evaluator
    def initialize(config)
      @config = config
      @database = Client.new(config.database_url)
    end


    # add digests to the database based on a list of file_paths
    # returns a report object
    def add_files(file_path_list)
      files = File.open(file_path_list).read.split("\n")
      ct_files = files.count
      files.each_with_index do |file_path, idx|
        add_file(file_path)
        puts "File added: #{file_path} - #{(idx/ct_files.to_f)}"
      end
    end

    def add_file(file_path)
      events = generate_events(file_path)
      digests = collect_digests(events)
      metadata = extract_metadata(file_path)
      database.add_media(file_path, metadata, digests)
    end

    def run_queries(query_path_list)
      queries = []
      File.open(query_path_list).read.split("\n").each do |file|
        queries << query(file)
      end
      queries
    end

    def query(query_path, threshold=nil)
      events = generate_events(query_path)
      digests = collect_digests(events)
      db_result = database.query(digests, threshold)
      r = run_scoring(db_result)
    end

    def evaluate
      @config.evaluator_class
    end

    def generate_events(file_path)
      run_generate_events(file_path)
    end

    def collect_digests(events)
      self.run_generate_digests(events)
    end

    # Each block shall return an Event array
    # The method retuns an array with all events collected
    def run_generate_events(file_path)
      event_list = []
      self.class.generate_events_strategies.each do |gen_event_strategy_block|
        event_list += gen_event_strategy_block.call(file_path, self)
      end
      EventList.new(event_list)
    end

    # Each block shall return a Digest array
    # The method retuns an array with all digests collected
    def run_generate_digests(event_list)
      digest_list = []
      self.class.generate_digests_strategies.each do |gen_digest_strategy_block|
        digest_list += gen_digest_strategy_block.call(EventList.new(event_list), self)
      end
      DigestList.new(digest_list)
    end

    def run_scoring(digest_list)
      r = digest_list.keys.map do |key|
        [key, self.class.scoring_var.call(key, digest_list)]
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
