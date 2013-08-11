module GoogleDistanceMatrix
  class Client
    CLIENT_ERRORS = %w[
      INVALID_REQUEST
      MAX_ELEMENTS_EXCEEDED
      OVER_QUERY_LIMIT
      REQUEST_DENIED
      UNKNOWN_ERROR
    ]

    def get(url, options = {})
      uri = URI.parse url
      instrumentation = {url: url}.merge(options[:instrumentation] || {})

      response = ActiveSupport::Notifications.instrument "client_request_matrix_data.google_distance_matrix", instrumentation do
        Net::HTTP.get_response uri
      end

      case response
      when Net::HTTPSuccess
        inspect_for_client_errors! response
      when Net::HTTPRequestURITooLong
        fail MatrixUrlTooLong.new url, UrlBuilder::MAX_URL_SIZE, response
      when Net::HTTPClientError
        fail ClientError.new response
      when Net::HTTPServerError
        fail ServerError.new response
      else # Handle this as a request error for now. Maybe fine tune this more later.
        fail ServerError.new response
      end
    rescue Timeout::Error => error
      fail ServerError.new error
    end


    private

    def inspect_for_client_errors!(response)
      status = JSON.parse(response.body).fetch "status"

      if CLIENT_ERRORS.include? status
        fail ClientError.new response, status
      end

      response
    end
  end
end
