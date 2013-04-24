class GoogleDistanceMatrix::UrlBuilder
  BASE_URL = "http://maps.googleapis.com/maps/api/distancematrix/json"

  attr_reader :matrix

  def initialize(matrix)
    @matrix = matrix
  end
end
