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
end
