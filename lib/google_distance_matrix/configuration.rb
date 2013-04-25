class GoogleDistanceMatrix::Configuration
  ATTRIBUTES = %w[sensor]

  attr_accessor *ATTRIBUTES

  def initialize
    self.sensor = false
  end

  def to_hash
    Hash[ATTRIBUTES.map { |attr| [attr, public_send(attr)] }]
  end
end
