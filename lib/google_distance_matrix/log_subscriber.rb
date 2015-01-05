module GoogleDistanceMatrix
  class LogSubscriber < ActiveSupport::LogSubscriber
    def client_request_matrix_data(event)
      logger.info "(#{event.duration}ms) (elements: #{event.payload[:elements]}) GET #{event.payload[:url]}", tag: :client
    end

    def logger
      GoogleDistanceMatrix.logger
    end
  end
end

GoogleDistanceMatrix::LogSubscriber.attach_to "google_distance_matrix"
