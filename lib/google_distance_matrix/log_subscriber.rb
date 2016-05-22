module GoogleDistanceMatrix
  class LogSubscriber < ActiveSupport::LogSubscriber
    attr_reader :logger, :config

    def initialize(logger: GoogleDistanceMatrix.logger, config: GoogleDistanceMatrix.default_configuration)
      super()

      @logger = logger
      @config = config
    end

    def client_request_matrix_data(event)
      url = filter_url! event.payload[:url]
      logger.info "(#{event.duration}ms) (elements: #{event.payload[:elements]}) GET #{url}", tag: :client
    end

    private

    def filter_url!(url)
      config.filter_parameters_in_logged_url.each do |param|
        url.gsub! %r{(#{param})=.*?(&|$)}, '\1=[FILTERED]\2'
      end

      url
    end
  end
end

GoogleDistanceMatrix::LogSubscriber.attach_to "google_distance_matrix"
