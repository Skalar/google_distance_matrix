module GoogleDistanceMatrix
  # Public: Has logic for doing finder operations on a matrix.
  class RoutesFinder

    attr_reader :matrix
    delegate :data, :origins, :destinations, to: :matrix


    def initialize(matrix)
      @matrix = matrix
    end



    # Public: Finds routes for given place.
    #
    # place   -  Either an origin or destination
    #
    # Returns the place's routes
    def routes_for(place)
      if origins.include? place
        routes_for_origin place
      elsif destinations.include? place
        routes_for_destination place
      else
        fail ArgumentError, "Given place not an origin nor destination."
      end
    end


    # Public: Finds a route for you based on one origin and destination
    #
    # origin        - A place representing the origin
    # destination   - A place representing the destination
    #
    # A Route for given origin and destination
    def route_for(options = {})
      options = options.with_indifferent_access

      if options[:origin].nil? || options[:destination].nil?
        fail ArgumentError, "Must provide origin and destination"
      end

      routes_for(options[:origin]).detect { |route| route.destination == options[:destination] }
    end


    def shortest_route_by_distance_to(place)
      routes_for(place).min_by &:distance_value
    end

    def shortest_route_by_duration_to(place)
      routes_for(place).min_by &:distance_value
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
