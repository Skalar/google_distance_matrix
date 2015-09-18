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

    ATTRIBUTES = %w[sensor mode avoid units language]

    API_DEFAULTS = {
      mode: "driving",
      units: "metric"
    }.with_indifferent_access

    attr_accessor *ATTRIBUTES, :protocol, :logger, :lat_lng_scale
    attr_accessor :google_business_api_client_id, :google_business_api_private_key, :google_api_key
    attr_accessor :cache


    validates :sensor, inclusion: {in: [true, false]}
    validates :mode, inclusion: {in: ["driving", "walking", "bicycling"]}, allow_blank: true
    validates :avoid, inclusion: {in: ["tolls", "highways"]}, allow_blank: true
    validates :units, inclusion: {in: ["metric", "imperial"]}, allow_blank: true

    validates :protocol, inclusion: {in: ["http", "https"]}, allow_blank: true


    def initialize
      self.sensor = false
      self.protocol = "http"
      self.lat_lng_scale = 5

      API_DEFAULTS.each_pair do |attr_name, value|
        self[attr_name] = value
      end
    end

    def to_param
      Hash[array_param]
    end

    def []=(attr_name, value)
      public_send "#{attr_name}=", value
    end


    private

    def array_param
      out = ATTRIBUTES.map { |attr| [attr, public_send(attr)] }.reject do |attr_and_value|
        attr_and_value[1].nil? || param_same_as_api_default?(attr_and_value)
      end

      if google_business_api_client_id.present?
        out << ['client', google_business_api_client_id]
      end

      if google_api_key.present?
        out << ['key', google_api_key]
      end

      out
    end

    def param_same_as_api_default?(param)
     API_DEFAULTS[param[0]] == param[1]
    end
  end
end
