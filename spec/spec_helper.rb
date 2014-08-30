require 'bundler/setup'
require 'google_distance_matrix'

require 'webmock/rspec'
require 'shoulda-matchers'

WebMock.disable_net_connect!
I18n.enforce_available_locales = false

module RecordedRequestHelpers
  def recorded_request_for(name)
    File.new path_to(name)
  end

  private

  def path_to(name)
    File.join File.dirname(__FILE__), "request_recordings", name.to_s
  end
end

RSpec.configure do |c|
  c.include RecordedRequestHelpers, :request_recordings
end
