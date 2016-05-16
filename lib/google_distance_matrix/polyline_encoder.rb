require_relative 'polyline_encoder/delta'

module GoogleDistanceMatrix
  # Encodes a set of lat/lng pairs in to a polyline
  # according to Google's Encoded Polyline Algorithm Format.
  #
  # See https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  class PolylineEncoder

    # Encodes a set of lat/lng pairs
    #
    # Example
    #   encoded = PolylineEncoder.encode [[lat, lng], [lat, lng]]
    def self.encode(array_of_lat_lng_pairs, precision: 1e5)
      new(array_of_lat_lng_pairs, precision: precision).encode
    end

    # Initialize a new encoder
    #
    # @see ::encode
    def initialize(array_of_lat_lng_pairs, precision: 1e5)
      @array_of_lat_lng_pairs = array_of_lat_lng_pairs
      @precision = precision
      @encoded = nil
    end

    # Encode and returns the encoded string
    def encode
      return @encoded if @encoded

      deltas = Delta.new(@array_of_lat_lng_pairs, precision: @precision).deltas


      @encoded
    end
  end
end
