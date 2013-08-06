module GoogleDistanceMatrix
  class ClientCache
    attr_reader :client, :cache

    def initialize(client, cache)
      @client = client
      @cache = cache
    end

    def get(url, options = {})
      cache.fetch url do
        client.get url, options
      end
    end
  end
end
