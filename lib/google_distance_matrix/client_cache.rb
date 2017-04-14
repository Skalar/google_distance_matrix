# frozen_string_literal: true

module GoogleDistanceMatrix
  # Cached client, which takes care of caching data from Google API
  class ClientCache
    attr_reader :client, :cache

    def self.key(url)
      url
    end

    def initialize(client, cache)
      @client = client
      @cache = cache
    end

    def get(url, options = {})
      cache.fetch self.class.key(url) do
        client.get url, options
      end
    end
  end
end
