class GoogleDistanceMatrix::Configuration
  include ActiveModel::Validations

  ATTRIBUTES = %w[sensor mode avoid units]

  attr_accessor *ATTRIBUTES


  validates :sensor, inclusion: {in: [true, false]}
  validates :mode, inclusion: {in: ["driving", "walking", "bicycling"]}, allow_blank: true
  validates :avoid, inclusion: {in: ["tolls", "highways"]}, allow_blank: true
  validates :units, inclusion: {in: ["metric", "imperial"]}, allow_blank: true


  def initialize
    self.sensor = false
  end

  def to_hash
    Hash[ATTRIBUTES.map { |attr| [attr, public_send(attr)] }]
  end
end
