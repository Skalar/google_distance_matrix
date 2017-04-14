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

    def get(url, options = {})
      uri = URI.parse url
      instrumentation = { url: url }.merge(options[:instrumentation] || {})

      response = ActiveSupport::Notifications.instrument(
        'client_request_matrix_data.google_distance_matrix', instrumentation
      ) do
        Net::HTTP.get_response uri
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
