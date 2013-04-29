# Public: Represents a place and knows how to convert it to param.
#
# Examples
#
#   GoogleDistanceMatrix::Place.new address: "My address"
#   GoogleDistanceMatrix::Place.new lat: 1, lng: 3
#
#   You may also build places by other objects responding to lat and lng or address.
#   If your object responds to all of the attributes we'll use lat and lng as data
#   for the Place.
#
#   GoogleDistanceMatrix::Place.new object
module GoogleDistanceMatrix
  class Place
    ATTRIBUTES = %w[address lat lng]

    attr_reader *ATTRIBUTES, :extracted_attributes_from

    def initialize(attributes_or_object)
      if respond_to_needed_attributes? attributes_or_object
        extract_and_assign_attributes_from_object attributes_or_object
      elsif attributes_or_object.is_a? Hash
        assign_attributes attributes_or_object
      else
        fail ArgumentError, "Must be either hash or object responding to lat, lng or address. "
      end

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

    def inspect
      inspection = (ATTRIBUTES | [:extracted_attributes_from]).reject { |a| public_send(a).blank? }.map { |a| "#{a}: #{public_send(a).inspect}" }.join ', '

      "#<#{self.class} #{inspection}>"
    end

    private

    def respond_to_needed_attributes?(object)
      (object.respond_to?(:lat) &&  object.respond_to?(:lng)) || object.respond_to?(:address)
    end

    def extract_and_assign_attributes_from_object(object)
      attrs =  Hash[ATTRIBUTES.map do |attr_name|
        if object.respond_to? attr_name
          [attr_name, object.public_send(attr_name)]
        end
      end.compact]

      if attrs.has_key?('lat') || attrs.has_key?('lng')
        attrs.delete 'address'
      end

      @extracted_attributes_from = object
      assign_attributes attrs
    end

    def assign_attributes(attributes)
      attributes = attributes.with_indifferent_access

      @address = attributes[:address]
      @lat = attributes[:lat]
      @lng = attributes[:lng]
    end

    def validate_attributes
     unless address.present? || (lat.present? && lng.present?)
        fail ArgumentError, "Must provide an address, or lat and lng."
      end

      if address.present? && lat.present? && lng.present?
        fail ArgumentError, "Cannot provide address, lat and lng."
      end
    end
  end
end
