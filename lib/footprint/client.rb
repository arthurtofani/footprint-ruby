module Footprint
  class Client
    def initialize(database_url="http://api:3000")
      @database_url = database_url
    end

    def clear!
      conn.post '/media/clear'
    end

    def add_media(file_path, metadata, digest_list)
      digests = digest_list.db_format
      conn.post '/media', {
                            path: file_path,
                            metadata: metadata,
                            digests: digests
                          }
    end

    def query(digest_list, threshold=1.0)
      JSON.parse(conn.post('/media/query', {threshold: threshold, digests: digest_list.db_format}).body)
    end

    private

    def conn
      @conn ||= Faraday.new(:url => @database_url) do |faraday|
        faraday.request  :url_encoded
        faraday.adapter  Faraday.default_adapter
      end
    end
  end
end
