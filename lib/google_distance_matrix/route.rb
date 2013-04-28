module GoogleDistanceMatrix
  # Public: Thin wrapper class for an element in the matrix.
  #
  # The route has the data the element contains, pluss it references
  # it's origin and destination.
  #
  class Route
    ATTRIBUTES = %w[
      origin destination
      status distance_text distance_value duration_text duration_value
    ]

    attr_reader *ATTRIBUTES

    def initialize(attributes = {})
      attributes = attributes.with_indifferent_access

      @origin = attributes[:origin]
      @destination = attributes[:destination]

      @status = attributes[:status]
      @distance_text = attributes[:distance][:text]
      @distance_value = attributes[:distance][:value]
      @duration_text = attributes[:duration][:text]
      @duration_value = attributes[:duration][:value]
    end

    def inspect
      inspection = ATTRIBUTES.reject { |a| public_send(a).blank? }.map { |a| "#{a}: #{public_send(a).inspect}" }.join ', '

      "#<#{self.class} #{inspection}>"
    end
  end
end
