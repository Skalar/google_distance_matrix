# frozen_string_literal: true

# rubocop:disable Style/NumericPredicate
module GoogleDistanceMatrix
  class PolylineEncoder
    # Encodes a single value, like 17998321, in to encoded polyline value,
    # as described in Google's documentation
    # https://developers.google.com/maps/documentation/utilities/polylinealgorithm
    #
    # This is an internal helper class for PolylineEncoder.
    # This encoder expects that the value is rounded.
    #
    # @see GoogleDistanceMatrix::PolylineEncoder
    class ValueEncoder
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def encode(value)
        negative = value < 0
        value = value.abs

        # Step 3: Two's complement when negative
        value = ~value + 1 if negative

        # Step 4: Left shift one bit
        value = value << 1

        # Step 5: Invert if value was negative
        value = ~value if negative

        # Step 6 and 7: 5-bit chunks in reverse order
        # We AND 5 first bits and push them on to chunks array.
        # Right shift bits to get rid of the ones we just put on the array.
        # Bits will end up in reverse order.
        chunks_of_5_bits = []
        while value > 0
          chunks_of_5_bits.push(value & 0x1f)
          value >>= 5
        end

        chunks_of_5_bits << 0 if chunks_of_5_bits.empty?

        # Step 8, 9 and 10: OR each value with 0x20, unless last one. Add 63 to all values
        last_index = chunks_of_5_bits.length - 1
        chunks_of_5_bits.each_with_index do |chunk, index|
          chunks_of_5_bits[index] = chunk | 0x20 unless index == last_index
          chunks_of_5_bits[index] += 63
        end

        # step 11: Convert to ASCII
        chunks_of_5_bits.map(&:chr)
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      private

      # Debug method for pretty printing integers as bits.
      #
      # Example of usage
      #   p d 17998321 # => "00000001 00010010 10100001 11110001"
      def d(v, bits = 32, chunk_size = 8)
        (bits - 1).downto(0)
                  .map { |n| v[n] }
                  .each_slice(chunk_size).map(&:join).join ' '
      end
    end
  end
end
