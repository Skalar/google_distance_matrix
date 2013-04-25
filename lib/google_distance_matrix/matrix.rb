module GoogleDistanceMatrix
  # Public: Represents a distance matrix.
  #
  # Enables you to set up a origins and destinations and get
  # a distance matrix from Google. For documentation see
  # https://developers.google.com/maps/documentation/distancematrix
  #
  # Examples
  #
  #   origin_1 = GoogleDistanceMatrix::Place.new address: "Karl Johans gate, Oslo"
  #   origin_2 = GoogleDistanceMatrix::Place.new address: "Askerveien 1, Asker"
  #
  #   destination_1 = GoogleDistanceMatrix::Place.new address: "Drammensveien 1, Oslo"
  #   destination_2 = GoogleDistanceMatrix::Place.new lat: 1.4, lng: 1.3
  #
  #   matrix = GoogleDistanceMatrix::Matrix.new(
  #     origins: [origin_1, origin_2],
  #     destinations: [destination_1, destination_2]
  #   )
  #
  # You may configure the matrix. See GoogleDistanceMatrix::Configuration for options.
  #
  #   matrix.configure do |config|
  #     config.sensor = true
  #     config.mode = "walking"
  #   end
  #
  # You can set default configuration by doing: GoogleDistanceMatrix.configure_defaults { |c| c.sensor = true }
  #
  #
  # Query API and get the matrix back
  #
  #   matrix.data   # Returns a two dimensional array.
  #                 # Rows are ordered according to the values in the origins.
  #                 # Each row corresponds to an origin, and each element within that row corresponds to
  #                 # a pairing of the origin with a destination.
  #
  #
  class Matrix
    include ActiveModel::Validations

    validates :origins, length: {minimum: 1, too_short: "must have at least one origin"}
    validates :destinations, length: {minimum: 1, too_short: "must have at least one destination"}
    validate { errors.add(:configuration, "is invalid") if configuration.invalid? }

    attr_reader :origins, :destinations, :configuration

    def initialize(attributes = {})
      attributes = attributes.with_indifferent_access

      @origins = Places.new attributes[:origins]
      @destinations = Places.new attributes[:destinations]
      @configuration = attributes[:configuration] || GoogleDistanceMatrix.default_configuration.dup
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

      routes_for(options).first
    end

    # Public: Finds routes for you based on an origin or a destination
    #
    # You may give both origin and destination as well. You'll get one route
    # back wrapped in an array. See route_for and use it instead.
    #
    # origin        - A place representing the origin
    # destination   - A place representing the destination
    #
    # Routes for given origin or destination
    def routes_for(options = {})
      options = options.with_indifferent_access

      origin = options[:origin]
      destination = options[:destination]

      if origin && destination
        origin_index = origins.index origin
        destination_index = destinations.index destination

        if origin_index.nil? || destination_index.nil?
          fail ArgumentError, "Given origin or destination is not i matrix."
        end

        [data[origin_index][destination_index]]
      elsif origin
        index = origins.index origin

        if index.nil?
          fail ArgumentError, "Given origin is not i matrix."
        end

        data[index]
      elsif destination
        index = destinations.index destination

        if index.nil?
          fail ArgumentError, "Given destination is not i matrix."
        end

        routes = []

        data.each do |row|
          routes << row[index]
        end

        routes
      else
        fail ArgumentError, "Must provide either origin, destination or both."
      end
    end


    # Public: The data for this matrix.
    #
    # Returns a two dimensional array, the matrix's data
    def data
      @data ||= load_matrix
    end



    def configure
      yield configuration
    end

    def url
      UrlBuilder.new(self).url
    end



    private

    def load_matrix
      parsed = JSON.parse client.get(url).body

      parsed["rows"].each_with_index.map do |row, origin_index|
        origin = origins[origin_index]

        row["elements"].each_with_index.map do |element, destination_index|
          route_attributes = element.merge(origin: origin, destination: destinations[destination_index])
          Route.new route_attributes
        end
      end
    end

    def client
      @client ||= Client.new
    end
end
end
