require 'taglib'
require 'pry'

module Footprint
  class System
    include Footprint::Observable
    include Footprint::Observer

    class << self
      attr_accessor :generate_events_strategies, :generate_digests_strategies, :scoring_methods, :combine_score_var, :hashing_var

      def generate_events(&block)
        @generate_events_strategies ||= []
        @generate_events_strategies << block
      end

      def generate_digests(&block)
        @generate_digests_strategies ||= []
        @generate_digests_strategies << block
      end

      def scoring(method_name='default', &block)
        @scoring_methods ||= {}
        @scoring_methods[method_name] = block
        @scoring_methods
      end

      def combine_scores(&block)
        @combine_score_var = block
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

    def run_queries(query_path_list, threshold=nil, random_amnt=nil)
      queries = []
      query_files = File.open(query_path_list).read.split("\n")
      query_files = query_files.sample(random_amnt) unless random_amnt.nil?
      query_files.each do |file|
        queries << query(file, threshold)
      end
      queries
    end

    def query(query_path, threshold=nil)
      notify_observers(CallbackEvents::QueryStartedEvent.new(query_path))
      query_events = generate_events(query_path)
      query_digests = collect_digests(query_events)

      query_time_start = Time.now
      db_result = database.query(query_digests, threshold)
      query_time_end = Time.now
      scoring_time_start = Time.now
      r = run_scoring(query_digests, db_result)
      scoring_time_end = Time.now
      evt = CallbackEvents::QueryPerformedEvent.new(query_path, r, query_events, query_digests, db_result)
      evt.query_time_start = query_time_start
      evt.query_time_end = query_time_end
      evt.scoring_time_start = scoring_time_start
      evt.scoring_time_end = scoring_time_end
      notify_observers(evt)
      r
    end

    def generate_queries(file_list, amount, seconds)
      #notify_observers(CallbackEvents::QueryGenerationStartedEvent.new(file_list, amount, seconds))
      result_list = AudioSlicer.new(self, file_list, amount, seconds).run
      #notify_observers(CallbackEvents::QueryGenerationFinishedEvent.new(file_list, amount, seconds, result_list))
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
      time_start = Time.now
      self.class.generate_events_strategies.each do |gen_event_strategy_block|
        event_list += gen_event_strategy_block.call(file_path, self)
      end
      ev_list = EventList.new(event_list)
      ev_list.time_start = time_start
      ev_list.cron_end!
      ev_list.file_path = file_path
      ev_list
    end

    # Each block shall return a Digest array
    # The method retuns an array with all digests collected
    def run_generate_digests(event_list)
      digest_list = []
      time_start = Time.now
      self.class.generate_digests_strategies.each do |gen_digest_strategy_block|
        digest_list += gen_digest_strategy_block.call(event_list, self)
      end
      digest_list.each{|digest| hash_digest(digest) }
      dl = DigestList.new(digest_list)
      dl.time_start = time_start
      dl.cron_end!
      dl
    end

    def run_scoring(query_digests, result_digests)
      results = self.class.scoring_methods.map.each do |method_name, scoring_method|
        r = result_digests.keys.map do |media_reference|
          [media_reference, scoring_method.call(media_reference, result_digests[media_reference], query_digests, self)]
        end
        [method_name, r.sort{|a, b| b[1]<=>a[1]}.to_h]
      end
      return results.last.last if self.class.combine_score_var.nil?
      self.class.combine_score_var.call(results)
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
