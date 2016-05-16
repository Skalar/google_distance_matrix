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
      def initialize(array_of_lat_lng_pairs, precision: 1e5)
        @array_of_lat_lng_pairs = array_of_lat_lng_pairs
        @precision = precision
        @deltas = nil
      end

      def deltas
        return @deltas if @deltas

        round_to_precision
        calculate_deltas

        @deltas
      end


      private

      def round_to_precision
        @array_of_lat_lng_pairs.each do |pair|
          pair[0] = (pair[0] * @precision).round
          pair[1] = (pair[1] * @precision).round
        end
      end

      def calculate_deltas
        @deltas = []

        delta_lat = 0
        delta_lng = 0

        @array_of_lat_lng_pairs.each do |(lat, lng)|
          @deltas << lat - delta_lat
          @deltas << lng - delta_lng

          delta_lat, delta_lng = lat, lng
        end
      end
    end
  end
end
