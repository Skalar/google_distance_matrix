module GoogleDistanceMatrix
  class UrlBuilder
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
