require 'thor'

module Footprint
  class Cli < Thor
    class_option :config
    class_option :list
    desc "add --config path/to/config.json",
         "Add files to the database"

    def add(files)
      footprint.add_files(files)
    end



    desc "stats",
         "Show server stats"
    def stats
      puts footprint.database.stats
    end


    desc "clear",
         "Clear database"
    def clear
      footprint.database.clear!
      puts "Database clean!"
    end



    desc "query path/to/files.txt --list --config path/to/config.json",
         "Inquiries database"
    def query(file)
      if options[:list].present?
        footprint.run_queries(file)
      else
        footprint.query(file)
      end
    end



    desc "evaluate --files path/to/files.txt --config path/to/config.json",
         "Evaluates database"
    def evaluate
      footprint.evaluate
    end

    class_option :amount
    class_option :seconds
    class_option :output_path
    desc "generate_queries path/to/files.txt --seconds 2 --amount 5",
         "Generates random queries with s seconds for all files in a given list"
    def generate_queries(file_list)
      footprint.generate_queries(file_list, options[:amount], options[:seconds])
    end



    private

    def footprint
      @footprint ||= Footprint::Config.load(options[:config]).init!
    end

  end
end
