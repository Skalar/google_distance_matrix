module GoogleDistanceMatrix
  class RoutesFinder

    attr_reader :matrix
    delegate :data, :origins, :destinations, to: :matrix


    def initialize(matrix)
      @matrix = matrix
    end


    def find(options = {})
      options = options.with_indifferent_access

      if options.has_key?(:origin) && options.has_key?(:destination)
        find_route_for_origin_and_destination options[:origin], options[:destination]
      elsif options.has_key? :origin
        routes_for_origin options[:origin]
      elsif options.has_key? :destination
        routes_for_destination options[:destination]
      else
        fail ArgumentError, "Must provide either origin, destination or both."
      end
    end




    private

    def routes_for_origin(origin)
      index = origins.index origin
      fail ArgumentError, "Given origin is not i matrix."if index.nil?

      data[index]
    end

    def routes_for_destination(destination)
      index = destinations.index destination
      fail ArgumentError, "Given destination is not i matrix." if index.nil?

      [].tap do |routes|
        data.each { |row| routes << row[index] }
      end
    end

    def find_route_for_origin_and_destination(origin, destination)
      origin_index = origins.index origin
      destination_index = destinations.index destination

      if origin_index.nil? || destination_index.nil?
        fail ArgumentError, "Given origin or destination is not i matrix."
      end

      [data[origin_index][destination_index]]
    end
  end
end
