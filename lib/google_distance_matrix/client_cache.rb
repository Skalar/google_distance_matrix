# frozen_string_literal: true

module GoogleDistanceMatrix
  # Cached client, which takes care of caching data from Google API
  class ClientCache
    attr_reader :client, :cache

    # Returns a cache key for given URL
    #
    # @return String
    def self.key(url, config)
      config.cache_key_transform.call url
    end

    def initialize(client, cache)
      @client = client
      @cache = cache
    end

    def get(url, options = {})
      cache.fetch self.class.key(url, options.fetch(:configuration)) do
        client.get url, **options
      end
    end
  end
end
