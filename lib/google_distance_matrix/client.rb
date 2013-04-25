class GoogleDistanceMatrix::Client
  CLIENT_ERRORS = %w[
    INVALID_REQUEST
    MAX_ELEMENTS_EXCEEDED
    OVER_QUERY_LIMIT
    REQUEST_DENIED
    UNKNOWN_ERROR
  ]

  def get(url)
    uri = URI.parse URI.encode(url)
    response = Net::HTTP.get_response uri

    case response
    when Net::HTTPSuccess
      inspect_for_client_errors! response
    when Net::HTTPInternalServerError
      fail GoogleDistanceMatrix::RequestError.new response
    end
  rescue Timeout::Error => error
    fail GoogleDistanceMatrix::RequestError.new error
  end


  private

  def inspect_for_client_errors!(response)
    status = JSON.parse(response.body).fetch "status"

    if CLIENT_ERRORS.include? status
      fail GoogleDistanceMatrix::ClientError.new response, status
    end

    response
  end
end
