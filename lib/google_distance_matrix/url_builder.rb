# frozen_string_literal: true

require_relative 'url_builder/polyline_encoder_buffer'

module GoogleDistanceMatrix
  # Takes care of building the url for given matrix
  class UrlBuilder
    BASE_URL = 'maps.googleapis.com/maps/api/distancematrix/json'
    DELIMITER = CGI.escape('|')
    MAX_URL_SIZE = 2048

    attr_reader :matrix
    delegate :configuration, to: :matrix

    def initialize(matrix)
      @matrix = matrix

      raise InvalidMatrix, matrix if matrix.invalid?
    end

    # Returns the URL we'll call Google API with
    #
    # This URL contains key and signature and is therefor
    # sensitive.
    #
    # @return String
    # @see filtered_url
    def sensitive_url
      @sensitive_url ||= build_url
    end

    # Returns the URL filtered as the configuration of the matrix dictates
    #
    # @return String
    def filtered_url
      filter_url sensitive_url
    end

    private

    def build_url
      url = [protocol, BASE_URL, '?', query_params_string].join

      if sign_url?
        url = GoogleBusinessApiUrlSigner.add_signature(
          url, configuration.google_business_api_private_key
        )
      end

      raise MatrixUrlTooLong.new url, MAX_URL_SIZE if url.length > MAX_URL_SIZE

      url
    end

    def filter_url(url)
      configuration.filter_parameters_in_logged_url.each do |param|
        url = url.gsub(/(#{param})=.*?(&|$)/, '\1=[FILTERED]\2')
      end

      url
    end

    def sign_url?
      configuration.google_business_api_client_id.present? &&
        configuration.google_business_api_private_key.present?
    end

    def include_api_key?
      configuration.google_api_key.present?
    end

    def query_params_string
      params.to_a.map { |key_value| key_value.join('=') }.join('&')
    end

    def params
      configuration.to_param.merge(
        origins: places_to_param(matrix.origins),
        destinations: places_to_param(matrix.destinations)
      )
    end

    # rubocop:disable Metrics/MethodLength
    def places_to_param(places)
      places_to_param_config = { lat_lng_scale: configuration.lat_lng_scale }

      out = []
      polyline_encode_buffer = PolylineEncoderBuffer.new

      places.each do |place|
        if place.lat_lng? && configuration.use_encoded_polylines
          polyline_encode_buffer << place.lat_lng
        else
          polyline_encode_buffer.flush to: out
          out << escape(place.to_param(places_to_param_config))
        end
      end

      polyline_encode_buffer.flush to: out

      out.join(DELIMITER)
    end
    # rubocop:enable Metrics/MethodLength

    def protocol
      configuration.protocol + '://'
    end

    def escape(string)
      CGI.escape string
    end
  end
end
