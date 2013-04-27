module GoogleDistanceMatrix
  class Railtie < Rails::Railtie
    initializer "google_distance_matrix.logger_setup" do
      GoogleDistanceMatrix.configure_defaults do |config|
        config.logger = Rails.logger
      end
    end
  end
end
