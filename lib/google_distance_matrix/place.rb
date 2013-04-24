class GoogleDistanceMatrix::Place
  attr_accessor :address, :lat, :lng

  def initialize(attributes = {})
    attributes = ActiveSupport::HashWithIndifferentAccess.new attributes

    self.address = attributes[:address]
    self.lat = attributes[:lat]
    self.lng = attributes[:lng]

    validate_attributes
  end


  def eql?(other)
    if address.present?
      address == other.address
    else
      lat == other.lat && lng == other.lng
    end
  end


  private

  def validate_attributes
   unless address.present? || (lat.present? && lng.present?)
      fail ArgumentError, "Must provide an address, or lat and lng."
    end

    if address.present? && lat.present? && lng.present?
      fail ArgumentError, "Cannot provide address, lat and lng."
    end
  end
end
