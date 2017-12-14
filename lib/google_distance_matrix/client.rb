# frozen_string_literal: true

module GoogleDistanceMatrix
  # HTTP client making request to Google's API
  class Client
    CLIENT_ERRORS = %w[
      INVALID_REQUEST
      MAX_ELEMENTS_EXCEEDED
      OVER_QUERY_LIMIT
      REQUEST_DENIED
      UNKNOWN_ERROR
    ].freeze

    # Make a GET request to given URL
    #
    # @param url              The URL to Google's API we'll make a request to
    # @param instrumentation  A hash with instrumentation payload
    # @param configuration    Instance of Configuration telling us what timeout
    #                         to use, for instance
    #
    # @return Hash with data from parsed response body
    def get(url, instrumentation: {}, configuration: nil)
      uri = URI.parse url
      http = Net::HTTP.new uri.host, uri.port

      http.use_ssl = uri.scheme == "https"

      if timeout = configuration && configuration.timeout
        http.read_timeout = timeout
        http.open_timeout = timeout
      end

      response = ActiveSupport::Notifications.instrument(
        'client_request_matrix_data.google_distance_matrix', instrumentation
      ) do
        http.start do |client|
          client.request_get uri
        end
      end

      handle response, url
    rescue Timeout::Error => error
      raise ServerError, error
    end

    private

    def handle(response, url) # rubocop:disable Metrics/MethodLength
      case response
      when Net::HTTPSuccess
        inspect_for_client_errors! response
      when Net::HTTPRequestURITooLong
        raise MatrixUrlTooLong.new url, UrlBuilder::MAX_URL_SIZE, response
      when Net::HTTPClientError
        raise ClientError, response
      when Net::HTTPServerError
        raise ServerError, response
      else # Handle this as a request error for now. Maybe fine tune this more later.
        raise ServerError, response
      end
    end

    def inspect_for_client_errors!(response)
      status = JSON.parse(response.body).fetch 'status'

      raise ClientError.new response, status if CLIENT_ERRORS.include? status

      response
    end
  end
end
