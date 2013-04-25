module GoogleDistanceMatrix
  # Public: Configuration of matrix and it's request.
  #
  # Holds configuration used when building API URL.
  #
  # See https://developers.google.com/maps/documentation/distancematrix/#RequestParameters
  # for documentation on each configuration.
  #
  class Configuration
    include ActiveModel::Validations

    ATTRIBUTES = %w[sensor mode avoid units]

    attr_accessor *ATTRIBUTES, :protocol


    validates :sensor, inclusion: {in: [true, false]}
    validates :mode, inclusion: {in: ["driving", "walking", "bicycling"]}, allow_blank: true
    validates :avoid, inclusion: {in: ["tolls", "highways"]}, allow_blank: true
    validates :units, inclusion: {in: ["metric", "imperial"]}, allow_blank: true


    def initialize
      self.sensor = false
    end

    def to_hash
      Hash[
        ATTRIBUTES.map { |attr| [attr, public_send(attr)] }.reject do |attr_and_value|
          attr_and_value[1].nil?
        end
      ]
    end
  end
end
