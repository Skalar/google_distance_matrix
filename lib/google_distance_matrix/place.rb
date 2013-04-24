class GoogleDistanceMatrix::Place
  attr_accessor :address, :lat, :lng

  def initialize(attributes = {})
    attributes = attributes.with_indifferent_access

    self.address = attributes[:address]
    self.lat = attributes[:lat]
    self.lng = attributes[:lng]

    validate_attributes
  end

  def to_param
    address.present? ? CGI.escape(address) : lat_lng.join(',')
  end


  def eql?(other)
    if address.present?
      address == other.address
    else
      lat_lng == other.lat_lng
    end
  end

  def lat_lng
    [lat, lng]
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
