# frozen_string_literal: true

require 'digest'

module GoogleDistanceMatrix
  # Cached client, which takes care of caching data from Google API
  class ClientCache
    attr_reader :client, :cache

    # Returns a cache key for given URL
    #
    # @return String
    def self.key(url)
      digest = Digest::SHA512.new
      digest << url
      digest.to_s
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
