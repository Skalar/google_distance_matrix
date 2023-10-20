# frozen_string_literal: true

require 'spec_helper'

module GoogleDistanceMatrix
  describe LogSubscriber do
    class MockLogger
      attr_reader :logged

      def initialize
        @logged = []
      end

      def info(msg, _tag)
        @logged << msg
      end

      def error(msg)
        raise msg
      end

      def level
        1
      end
    end

    # Little helper to clean up examples
    def notify(instrumentation)
      ActiveSupport::Notifications.instrument(
        'client_request_matrix_data.google_distance_matrix', instrumentation
      ) do
      end
    end

    let(:mock_logger) { MockLogger.new }
    let(:config) { Configuration.new }

    # Attach our own test logger, re-attach the original attached log subscriber after test.
    before do
      @old_subscribers = LogSubscriber.subscribers.dup
      LogSubscriber.subscribers.clear
      LogSubscriber.attach_to 'google_distance_matrix',
                              LogSubscriber.new(logger: mock_logger, config: config)
    end

    after do
      @old_subscribers.each do |subscriber|
        LogSubscriber.attach_to 'google_distance_matrix', subscriber
      end
    end

    it 'logs the url and elements' do
      url = 'https://example.com'
      instrumentation = { filtered_url: url, elements: 0 }

      expect { notify instrumentation }.to change(mock_logger.logged, :length).from(0).to 1

      expect(mock_logger.logged.first).to include '(elements: 0) GET https://example.com'
    end
  end
end
