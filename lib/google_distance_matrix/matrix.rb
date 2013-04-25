class GoogleDistanceMatrix::Matrix
  include ActiveModel::Validations

  validates :origins, length: {minimum: 1, too_short: "must have at least one origin"}
  validates :destinations, length: {minimum: 1, too_short: "must have at least one destination"}
  validate { errors.add(:configuration, "is invalid") if configuration.invalid? }

  attr_reader :origins, :destinations, :configuration

  def initialize(attributes = {})
    attributes = attributes.with_indifferent_access

    @origins = GoogleDistanceMatrix::Places.new attributes[:origins]
    @destinations = GoogleDistanceMatrix::Places.new attributes[:destinations]
    @configuration = attributes[:configuration] || GoogleDistanceMatrix.default_configuration.dup
  end


  def matrix
    @matrix ||= load_matrix
  end



  def configure
    yield configuration
  end

  def url
    GoogleDistanceMatrix::UrlBuilder.new(self).url
  end



  private

  def load_matrix
    response = client.get url
    parsed = JSON.parse response.body

    parsed["rows"].each_with_index.map do |row, origin_index|
      origin = origins[origin_index]

      row["elements"].each_with_index.map do |element, destination_index|
        route_attributes = element.merge(origin: origin, destination: destinations[destination_index])
        GoogleDistanceMatrix::Route.new route_attributes
      end
    end
  end

  def client
    @client ||= GoogleDistanceMatrix::Client.new
  end
end
