# frozen_string_literal: true

require 'spec_helper'

describe GoogleDistanceMatrix::Client, :request_recordings do
  let(:origin_1) { GoogleDistanceMatrix::Place.new address: 'Karl Johans gate, Oslo' }
  let(:destination_1) { GoogleDistanceMatrix::Place.new address: 'Drammensveien 1, Oslo' }
  let(:matrix) do
    GoogleDistanceMatrix::Matrix.new(origins: [origin_1], destinations: [destination_1])
  end

  let(:url_builder) { GoogleDistanceMatrix::UrlBuilder.new matrix }
  let(:url) { url_builder.sensitive_url }

  subject { GoogleDistanceMatrix::Client.new }

  describe 'success' do
    before { stub_request(:get, url).to_return body: recorded_request_for(:success) }

    it 'makes the request' do
      expect(subject.get(url_builder.sensitive_url).body).to eq recorded_request_for(:success).read
    end
  end

  describe 'client errors' do
    describe 'server issues 4xx client error' do
      it 'wraps the error http response' do
        stub_request(:get, url).to_return status: [400, 'Client error']
        expect { subject.get(url_builder.sensitive_url) }
          .to raise_error GoogleDistanceMatrix::ClientError
      end

      it 'wraps uri too long error' do
        stub_request(:get, url).to_return status: [414, 'Client error']
        expect { subject.get(url_builder.sensitive_url) }
          .to raise_error GoogleDistanceMatrix::MatrixUrlTooLong
      end
    end

    described_class::CLIENT_ERRORS.each do |error|
      it "wraps '#{error}' client error" do
        stub_request(:get, url).to_return body: JSON.generate(status: error)
        expect { subject.get(url_builder.sensitive_url) }
          .to raise_error GoogleDistanceMatrix::ClientError
      end
    end
  end

  describe 'request errors' do
    describe 'server error' do
      before { stub_request(:get, url).to_return status: [500, 'Internal Server Error'] }

      it 'wraps the error http response' do
        expect { subject.get(url_builder.sensitive_url) }
          .to raise_error GoogleDistanceMatrix::ServerError
      end
    end

    describe 'timeout' do
      before { stub_request(:get, url).to_timeout }

      it 'wraps the error from Net::HTTP' do
        expect { subject.get(url_builder.sensitive_url).body }
          .to raise_error GoogleDistanceMatrix::ServerError
      end
    end

    describe 'server error' do
      before { stub_request(:get, url).to_return status: [999, 'Unknown'] }

      it 'wraps the error http response' do
        expect { subject.get(url_builder.sensitive_url) }
          .to raise_error GoogleDistanceMatrix::ServerError
      end
    end
  end
end
