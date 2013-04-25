class GoogleDistanceMatrix::Route
  attr_reader :status, :distance_text, :distance_value, :duration_text, :duration_value

  def initialize(attributes = {})
    attributes = attributes.with_indifferent_access

    @status = attributes[:status]
    @distance_text = attributes[:distance][:text]
    @distance_value = attributes[:distance][:value]
    @duration_text = attributes[:duration][:text]
    @duration_value = attributes[:duration][:value]
  end
end
