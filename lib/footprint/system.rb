require 'taglib'
require 'pry'

module Footprint
  class System
    include Footprint::Observable
    include Footprint::Observer

    class << self
      attr_accessor :generate_events_strategies, :generate_digests_strategies, :scoring_var, :hashing_var

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

      def hashing(&block)
        @hashing_var = block
      end

    end

    attr_reader :database, :config
    attr_accessor :evaluator
    def initialize(config)
      @config = config
      @database = Client.new(config)
      add_observer(self)
      notify_observers(CallbackEvents::StartEvent.new)
    end


    # add digests to the database based on a list of file_paths
    # returns a report object
    def add_files(file_list_path)
      files = File.open(file_list_path).read.split("\n")
      ct_files = files.count
      file_added_events = []
      files.each_with_index do |file_path, idx|
        file_added_events << add_file(file_path)
        puts "File added: #{file_path} - #{(100*idx/ct_files.to_f)}%"
      end
      event = CallbackEvents::MultipleFilesAddedEvent.new(file_list_path, file_added_events)
      notify_observers(event)
      event
    end

    def add_file(file_path)
      events = generate_events(file_path)
      digests = collect_digests(events)
      metadata = extract_metadata(file_path)
      database.add_media(file_path, metadata, digests)
      event = CallbackEvents::FileAddedEvent.new(file_path, events, digests)
      notify_observers(event)
      event
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
      evaluator.evaluate
    end

    def hash_digest(digest)
      hsh = self.class.hashing_var.call(digest.digest)
      prev_digest = digest.digest
      digest.digest = hsh
      event = CallbackEvents::DigestHashedEvent.new(digest, prev_digest)
      notify_observers(event)
      digest
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
      ev_list = EventList.new(event_list)
      ev_list.file_path = file_path
      ev_list
    end

    # Each block shall return a Digest array
    # The method retuns an array with all digests collected
    def run_generate_digests(event_list)
      digest_list = []
      self.class.generate_digests_strategies.each do |gen_digest_strategy_block|
        digest_list += gen_digest_strategy_block.call(event_list, self)
      end
      digest_list.each{|digest| hash_digest(digest) }
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
