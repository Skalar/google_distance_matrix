# frozen_string_literal: true

module GoogleDistanceMatrix
  # Public: Configuration of matrix and it's request.
  #
  # Holds configuration used when building API URL.
  #
  # See https://developers.google.com/maps/documentation/distance-matrix/intro
  # for documentation on each configuration.
  #
  class Configuration
    include ActiveModel::Validations

    # Attributes we'll include building URL for our matrix
    ATTRIBUTES = %w[
      mode avoid units language
      departure_time arrival_time
      transit_mode transit_routing_preference
      traffic_model
    ].freeze

    API_DEFAULTS = {
      mode: 'driving',
      units: 'metric',
      traffic_model: 'best_guess',
      use_encoded_polylines: false,
      protocol: 'https',
      lat_lng_scale: 5,
      filter_parameters_in_logged_url: %w[key signature].freeze
    }.with_indifferent_access

    attr_accessor(*ATTRIBUTES)

    # The protocol to use, either http or https
    attr_accessor :protocol

    # lat_lng_scale is used for each Place when we include it's lat and lng values in the URL.
    # Defaults to 5 decimals, but you can set it lower to save characters in the URL.
    #
    # Speaking of saving characters. If you use_encoded_polylines all Places which has lat/lng
    # will use encoded set of coordinates using the Encoded Polyline Algorithm.
    # This is particularly useful if you have a large number of origin points,
    # because the URL is significantly shorter when using an encoded polyline.
    # See: https://developers.google.com/maps/documentation/distance-matrix/intro#RequestParameters
    attr_accessor :lat_lng_scale, :use_encoded_polylines

    # Google credentials
    attr_accessor :google_business_api_client_id, :google_business_api_private_key, :google_api_key

    attr_accessor :cache, :logger

    # When logging we filter sensitive parameters
    attr_accessor :filter_parameters_in_logged_url

    validates :mode, inclusion: { in: %w[driving walking bicycling transit] }, allow_blank: true
    validates :avoid, inclusion: { in: %w[tolls highways ferries indoor] }, allow_blank: true
    validates :units, inclusion: { in: %w[metric imperial] }, allow_blank: true

    validates :departure_time, format: /\A(\d+|now)\Z/, allow_blank: true
    validates :arrival_time, numericality: true, allow_blank: true

    validates :transit_mode,
              inclusion: { in: %w[bus subway train tram rail] },
              allow_blank: true

    validates :transit_routing_preference,
              inclusion: { in: %w[less_walking fewer_transfers] },
              allow_blank: true

    validates :traffic_model,
              inclusion: { in: %w[best_guess pessimistic optimistic] },
              allow_blank: true

    validates :protocol, inclusion: { in: %w[http https] }, allow_blank: true

    def initialize
      API_DEFAULTS.each_pair do |attr_name, value|
        self[attr_name] = begin
                            value.dup
                          rescue
                            value
                          end
      end
    end

    def to_param
      Hash[array_param]
    end

    def []=(attr_name, value)
      public_send "#{attr_name}=", value
    end

    private

    def array_param
      out = ATTRIBUTES.map { |attr| [attr, public_send(attr)] }.reject do |attr_and_value|
        attr_and_value[1].nil? || param_same_as_api_default?(attr_and_value)
      end

      if google_business_api_client_id.present?
        out << ['client', google_business_api_client_id]
      end

      out << ['key', google_api_key] if google_api_key.present?

      out
    end

    def param_same_as_api_default?(param)
      API_DEFAULTS[param[0]] == param[1]
    end
  end
end
