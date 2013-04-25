module GoogleDistanceMatrix
  class Error < StandardError
  end

  class MatrixUrlTooLong < Error
  end

  class InvalidMatrix < Error
    def initialize(matrix)
      @matrix = matrix
    end

    def to_s
      @matrix.errors.full_messages.to_sentence
    end
  end

  class RequestError < Error
    attr_reader :error_or_response

    def initialize(error_or_response)
      @error_or_response = error_or_response
    end

    def to_s
      "GoogleDistanceMatrix::RequestError - #{error_or_response.inspect}."
    end
  end

  class ClientError < Error
    attr_reader :response, :status_read_from_api_response

    def initialize(response, status_read_from_api_response = nil)
      @response = response
      @status_read_from_api_response = status_read_from_api_response
    end

    def to_s
      "GoogleDistanceMatrix::ClientError - #{[response, status_read_from_api_response].compact.join('. ')}."
    end
  end
end
