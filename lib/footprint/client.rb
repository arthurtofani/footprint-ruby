require 'faraday'
module Footprint
  class Client
    def initialize(config, database_url="http://api:3000")
      @config = config
      @database_url = config.database_url
    end

    def clear!
      conn.post "/buckets/#{@config.bucket}/clear"
    end

    def stats
      JSON.parse(conn.get('/media/stats').body)
    end

    def add_media(file_path, metadata, digest_list)
      digests = digest_list.db_format
      conn.post "/buckets/#{@config.bucket}/media", {
                            path: file_path,
                            metadata: metadata,
                            digests: digests,
                            bucket: @config.bucket
                          }
    end

    def query(digest_list, threshold)
      url = "/buckets/#{@config.bucket}/query"
      obj = {digests: digest_list.db_format, stopwords_threshold: threshold}
      JSON.parse(conn.post(url, obj).body)
    end

    private

    def conn
      @conn ||= Faraday.new(:url => @database_url) do |faraday|
        faraday.request  :url_encoded
        faraday.options[:open_timeout] = 300
        faraday.options[:timeout] = 300
        faraday.adapter  Faraday.default_adapter
      end
    end
  end
end
