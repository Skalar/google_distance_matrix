# frozen_string_literal: true

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
  # You can set default configuration by doing:
  # GoogleDistanceMatrix.configure_defaults { |c| c.sensor = true }
  #
  #
  # Query API and get the matrix back
  #
  #   matrix.data   # Returns a two dimensional array.
  #                 # Rows are ordered according to the values in the origins.
  #                 # Each row corresponds to an origin, and each element
  #                 # within that row corresponds to
  #                 # a pairing of the origin with a destination.
  #
  #
  class Matrix
    include ActiveModel::Validations

    validates :origins, length: { minimum: 1, too_short: 'must have at least one origin' }
    validates :destinations, length: { minimum: 1, too_short: 'must have at least one destination' }
    validate { errors.add(:configuration, 'is invalid') if configuration.invalid? }

    attr_reader :origins, :destinations, :configuration

    def initialize(attributes = {})
      attributes = attributes.with_indifferent_access

      @origins = Places.new attributes[:origins]
      @destinations = Places.new attributes[:destinations]
      @configuration = attributes[:configuration] || GoogleDistanceMatrix.default_configuration.dup
    end

    delegate :sensitive_url, :filtered_url, to: :url_builder

    delegate :route_for,  :routes_for,  to: :routes_finder
    delegate :route_for!, :routes_for!, to: :routes_finder
    delegate :shortest_route_by_distance_to,  :shortest_route_by_duration_to,   to: :routes_finder
    delegate :shortest_route_by_distance_to!, :shortest_route_by_duration_to!,  to: :routes_finder
    delegate :shortest_route_by_duration_in_traffic_to,  to: :routes_finder
    delegate :shortest_route_by_duration_in_traffic_to!, to: :routes_finder

    # Public: The data for this matrix.
    #
    # Returns a two dimensional array, the matrix's data
    def data
      @data ||= load_matrix
    end

    def reload
      clear_from_cache!
      @data = load_matrix
      self
    end

    def reset!
      @data = nil
    end

    def loaded?
      @data.present?
    end

    def configure
      yield configuration
    end

    def inspect
      attributes = %w[origins destinations]
      attributes << 'data' if loaded?
      inspection = attributes.map { |a| "#{a}: #{public_send(a).inspect}" }.join ', '

      "#<#{self.class} #{inspection}>"
    end

    private

    def url_builder
      # We do not keep url builder as an instance variable as origins and destinations
      # may be added after URL is being built for the first time. We should either
      # make our matrix immutable or reset if origins/destinations are added after data (and
      # the url) first being built and data fetched.
      UrlBuilder.new self
    end

    def routes_finder
      @routes_finder ||= RoutesFinder.new self
    end

    def load_matrix
      body = client.get(
        sensitive_url,
        instrumentation: instrumentation_for_api_request,
        configuration: configuration
      ).body

      parsed = JSON.parse(body)
      create_route_objects_for_parsed_data parsed
    end

    def instrumentation_for_api_request
      {
        elements: origins.length * destinations.length,
        sensitive_url: sensitive_url,
        filtered_url: filtered_url
      }
    end

    def create_route_objects_for_parsed_data(parsed)
      parsed['rows'].each_with_index.map do |row, origin_index|
        origin = origins[origin_index]

        row['elements'].each_with_index.map do |element, destination_index|
          route_attributes = element.merge(
            origin: origin, destination: destinations[destination_index]
          )
          Route.new route_attributes
        end
      end
    end

    def client
      client = Client.new

      if configuration.cache
        ClientCache.new client, configuration.cache
      else
        client
      end
    end

    def clear_from_cache!
      return if configuration.cache.nil?

      configuration.cache.delete ClientCache.key(sensitive_url, configuration)
    end
  end
end
