module GoogleDistanceMatrix
  class UrlBuilder
    BASE_URL = "http://maps.googleapis.com/maps/api/distancematrix/json"
    DELIMITER = "|"
    MAX_URL_SIZE = 2048

    attr_reader :matrix

    def initialize(matrix)
      @matrix = matrix

      fail InvalidMatrix.new matrix if matrix.invalid?
    end

    def url
      @url ||= build_url
    end


    private

    def build_url
      [BASE_URL, "?", get_params_string].join.tap do |url|
        if url.length > MAX_URL_SIZE
          fail MatrixUrlTooLong, "Matrix API URL max size is: #{MAX_URL_SIZE}. Built URL was: #{url.length}"
        end
      end
    end

    def get_params_string
      params.to_a.map { |key_value| key_value.join("=") }.join("&")
    end

    def params
      matrix.configuration.to_hash.merge(
        origins: matrix.origins.map(&:to_param).join(DELIMITER),
        destinations: matrix.destinations.map(&:to_param).join(DELIMITER),
      )
    end
  end
end
