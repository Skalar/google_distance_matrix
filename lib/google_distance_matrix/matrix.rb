class GoogleDistanceMatrix::Matrix
  attr_reader :origins, :destinations

  def initialize(attributes = {})
    attributes = attributes.with_indifferent_access

    @origins = Set.new attributes[:origins]
    @destinations = Set.new attributes[:destinations]
  end
end
