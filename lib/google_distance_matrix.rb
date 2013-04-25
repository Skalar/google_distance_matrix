require "google_distance_matrix/version"

require "cgi"
require "active_model"
require "active_support/core_ext/hash"

require "google_distance_matrix/place"
require "google_distance_matrix/matrix"
require "google_distance_matrix/url_builder"
require "google_distance_matrix/errors"
require "google_distance_matrix/configuration"

module GoogleDistanceMatrix
  extend self

  def default_configuration
    @default_configuration ||= Configuration.new
  end

  def configure_defaults
    yield default_configuration
  end
end
