# frozen_string_literal: true

module GoogleDistanceMatrix
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
  class Place
    ATTRIBUTES = %w[address lat lng].freeze

    attr_reader(*ATTRIBUTES, :extracted_attributes_from)

    def initialize(attributes_or_object)
      if respond_to_needed_attributes? attributes_or_object
        extract_and_assign_attributes_from_object attributes_or_object
      elsif attributes_or_object.is_a? Hash
        @extracted_attributes_from = attributes_or_object.with_indifferent_access
        assign_attributes attributes_or_object
      else
        raise ArgumentError, 'Must be either hash or object responding to lat, lng or address. '
      end

      validate_attributes
    end

    def to_param(options = {})
      options = options.with_indifferent_access
      address.present? ? address : lat_lng(options[:lat_lng_scale]).join(',')
    end

    def eql?(other)
      if address.present?
        address == other.address
      else
        lat_lng == other.lat_lng
      end
    end

    def lat_lng?
      lat.present? && lng.present?
    end

    def lat_lng(scale = nil)
      [lat, lng].map do |v|
        if scale
          v = v.to_f.round scale
          v == v.to_i ? v.to_i : v
        else
          v
        end
      end
    end

    def inspect
      inspection =  (ATTRIBUTES | [:extracted_attributes_from])
                    .reject { |a| public_send(a).blank? }
                    .map { |a| "#{a}: #{public_send(a).inspect}" }.join ', '

      "#<#{self.class} #{inspection}>"
    end

    private

    def respond_to_needed_attributes?(object)
      (object.respond_to?(:lat) && object.respond_to?(:lng)) || object.respond_to?(:address)
    end

    def extract_and_assign_attributes_from_object(object)
      attrs = Hash[ATTRIBUTES.map do |attr_name|
        [attr_name, object.public_send(attr_name)] if object.respond_to? attr_name
      end.compact]

      attrs.delete 'address' if attrs.key?('lat') || attrs.key?('lng')

      @extracted_attributes_from = object
      assign_attributes attrs
    end

    def assign_attributes(attributes)
      attributes = attributes.with_indifferent_access

      @address = attributes[:address]
      @lat = attributes[:lat]
      @lng = attributes[:lng]
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Style/GuardClause
    def validate_attributes
      unless address.present? || (lat.present? && lng.present?)
        raise ArgumentError, 'Must provide an address, or lat and lng.'
      end

      if address.present? && lat.present? && lng.present?
        raise ArgumentError, 'Cannot provide address, lat and lng.'
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Style/GuardClause
  end
end
