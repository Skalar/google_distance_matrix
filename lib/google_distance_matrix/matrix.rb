class GoogleDistanceMatrix::Matrix
  include ActiveModel::Validations

  validates :origins, length: {minimum: 1, too_short: "must have at least one origin"}
  validates :destinations, length: {minimum: 1, too_short: "must have at least one destination"}

  attr_reader :origins, :destinations, :configuration

  def initialize(attributes = {})
    attributes = attributes.with_indifferent_access

    @origins = Set.new attributes[:origins]
    @destinations = Set.new attributes[:destinations]
    @configuration = attributes[:configuration] || GoogleDistanceMatrix.default_configuration.dup

  def configure
    yield configuration
  end
  end
end
