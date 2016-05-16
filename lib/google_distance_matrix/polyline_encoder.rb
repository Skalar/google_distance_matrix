require_relative 'polyline_encoder/delta'
require_relative 'polyline_encoder/value_encoder'

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
    def self.encode(array_of_lat_lng_pairs)
      new(array_of_lat_lng_pairs).encode
    end


    # Initialize a new encoder
    #
    # Arguments
    #   array_of_lat_lng_pairs    - The array of lat/lng pairs, like [[lat, lng], [lat, lng], ..etc]
    #   delta                     - An object responsible for rounding and calculate the deltas
    #                               between the given lat/lng pairs.
    #   value_encoder             - After deltas are calculated each value is passed to the encoder
    #                               to be encoded in to ASCII characters
    #
    # @see ::encode
    def initialize(array_of_lat_lng_pairs, delta: Delta.new, value_encoder: ValueEncoder.new)
      @array_of_lat_lng_pairs = array_of_lat_lng_pairs
      @delta = delta
      @value_encoder = value_encoder
      @encoded = nil
    end

    # Encode and returns the encoded string
    def encode
      return @encoded if @encoded

      deltas = @delta.deltas_rounded @array_of_lat_lng_pairs
      chars_array = deltas.map { |v| @value_encoder.encode v }

      @encoded = chars_array.join
    end
  end
end
