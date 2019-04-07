require 'faraday'
module Footprint
  class Client
    def initialize(config, database_url="http://api:3000")
      @config = config
      @database_url = config.database_url
    end

    def clear!
      conn.post '/media/clear'
    end

    def stats
      JSON.parse(conn.get('/media/stats').body)
    end

    def add_media(file_path, metadata, digest_list)
      digests = digest_list.db_format
      conn.post '/media', {
                            path: file_path,
                            metadata: metadata,
                            digests: digests
                          }
    end

    def query(digest_list)
      JSON.parse(conn.post('/media/query', {digests: digest_list.db_format}).body)
    end

    private

    def conn
      @conn ||= Faraday.new(:url => @database_url) do |faraday|
        faraday.request  :url_encoded
        faraday.options[:open_timeout] = 30
        faraday.options[:timeout] = 30
        faraday.adapter  Faraday.default_adapter
      end
    end
  end
end
