class GoogleDistanceMatrix::Matrix
  attr_reader :origins, :destinations

  def initialize
    @origins = Set.new
    @destinations = Set.new
  end
end
