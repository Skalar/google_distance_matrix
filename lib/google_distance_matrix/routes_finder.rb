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
    # place   -  Either an origin or destination, or an object which you built the place from
    #
    # Returns the place's routes
    def routes_for(place_or_object_place_was_built_from)
      place = ensure_place place_or_object_place_was_built_from

      if origins.include? place
        routes_for_origin place
      elsif destinations.include? place
        routes_for_destination place
      else
        fail ArgumentError, "Given place not an origin nor destination."
      end
    end

    # Public: Finds routes for given place.
    #
    # Behaviour is same as without a bang, except it fails unless all routes are ok.
    #
    def routes_for!(place_or_object_place_was_built_from)
      routes_for(place_or_object_place_was_built_from).tap do |routes|
        routes.each do |route|
          fail_unless_route_is_ok route
        end
      end
    end


    # Public: Finds a route for you based on one origin and destination
    #
    # origin        - A place representing the origin, or an object which you built the origin from
    # destination   - A place representing the destination, or an object which you built the destination from
    #
    # A Route for given origin and destination
    def route_for(options = {})
      options = options.with_indifferent_access

      origin = ensure_place options[:origin]
      destination = ensure_place options[:destination]

      if origin.nil? || destination.nil?
        fail ArgumentError, "Must provide origin and destination"
      end

      routes_for(origin).detect { |route| route.destination == destination }
    end

    # Public: Finds a route for you based on one origin and destination
    #
    # Behaviour is same as without a bang, except it fails unless route are ok.
    #
    def route_for!(options = {})
      route_for(options).tap do |route|
        fail_unless_route_is_ok route
      end
    end


    def shortest_route_by_distance_to(place_or_object_place_was_built_from)
      routes = routes_for place_or_object_place_was_built_from
      select_ok_routes(routes).min_by &:distance_in_meters
    end

    def shortest_route_by_distance_to!(place_or_object_place_was_built_from)
      routes_for!(place_or_object_place_was_built_from).min_by &:distance_in_meters
    end

    def shortest_route_by_duration_to(place_or_object_place_was_built_from)
      routes = routes_for place_or_object_place_was_built_from
      select_ok_routes(routes).min_by &:duration_in_seconds
    end

    def shortest_route_by_duration_to!(place_or_object_place_was_built_from)
      routes_for!(place_or_object_place_was_built_from).min_by &:duration_in_seconds
    end




    private

    def ensure_place(object)
      if object.is_a? Place
        object
      else
        find_place_for_object(origins, object) ||
        find_place_for_object(destinations, object)
      end
    end

    def find_place_for_object(collection, object)
      collection.detect do |place|
        place.extracted_attributes_from.present? &&
        place.extracted_attributes_from == object
      end
    end

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

    def fail_unless_route_is_ok(route)
      fail InvalidRoute.new route unless route.ok?
    end

    def select_ok_routes(routes)
      routes.select &:ok?
    end
  end
end
