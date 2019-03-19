require 'thor'

module Footprint
  class Cli < Thor
    class_option :config
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



    desc "query STRATEGY_NAME --files path/to/files.txt --config path/to/config.json",
         "Inquiries database"
    def query(file)
    end



    desc "evaluate STRATEGY_NAME --files path/to/files.txt --config path/to/config.json",
         "Evaluates database"
    def evaluate
      footprint.evaluate
    end

    private

    def footprint
      @footprint ||= Footprint::Config.load(options[:config]).init!
    end

  end
end
