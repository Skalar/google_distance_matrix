# frozen_string_literal: true

module GoogleDistanceMatrix
  class PolylineEncoder
    # Calculates deltas between lat_lng values, internal helper class for PolylineEncoder.
    #
    # According to the Google's polyline encoding spec:
    #   "Additionally, to conserve space, points only include the offset
    #   from the previous point (except of course for the first point)"
    #
    # @see GoogleDistanceMatrix::PolylineEncoder
    class Delta
      def initialize(precision = 1e5)
        @precision = precision
      end

      # Takes a set of lat/lng pairs and calculates delta
      #
      # Returns a flatten array where each lat/lng delta pair is put in order.
      def deltas_rounded(array_of_lat_lng_pairs)
        rounded = round_to_precision array_of_lat_lng_pairs
        calculate_deltas rounded
      end

      private

      def round_to_precision(array_of_lat_lng_pairs)
        array_of_lat_lng_pairs.map do |(lat, lng)|
          [
            (lat * @precision).round,
            (lng * @precision).round
          ]
        end
      end

      def calculate_deltas(rounded)
        deltas = []

        delta_lat = 0
        delta_lng = 0

        rounded.each do |(lat, lng)|
          deltas << lat - delta_lat
          deltas << lng - delta_lng

          delta_lat = lat
          delta_lng = lng
        end

        deltas
      end
    end
  end
end
