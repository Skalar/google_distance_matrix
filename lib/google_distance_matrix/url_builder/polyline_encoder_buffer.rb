# frozen_string_literal: true

module GoogleDistanceMatrix
  class UrlBuilder
    # A buffer to contain Polyline Encoder
    class PolylineEncoderBuffer
      def initialize
        @buffer = []
      end

      def <<(lat_lng)
        @buffer << lat_lng
      end

      def flush(to:)
        return if @buffer.empty?

        to << escape("enc:#{PolylineEncoder.encode @buffer}:")
        @buffer.clear
      end

      private

      def escape(string)
        CGI.escape string
      end
    end
  end
end
