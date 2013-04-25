require "spec_helper"

describe GoogleDistanceMatrix::Client, :request_recordings do
  let(:origin_1) { GoogleDistanceMatrix::Place.new address: "Karl Johans gate, Oslo" }
  let(:destination_1) { GoogleDistanceMatrix::Place.new address: "Drammensveien 1, Oslo" }
  let(:matrix) { GoogleDistanceMatrix::Matrix.new(origins: [origin_1], destinations: [destination_1]) }
  let(:url_builder) { GoogleDistanceMatrix::UrlBuilder.new matrix }

  subject { GoogleDistanceMatrix::Client.new }

  describe "success" do
    before { stub_request(:get, URI.encode(url_builder.url)).to_return body: recorded_request_for(:success) }

    it "makes the request" do
      expect(subject.get(url_builder.url).body).to eq recorded_request_for(:success).read
    end
  end

  describe "client errors" do
    described_class::CLIENT_ERRORS.each do |error|
      it "wraps '#{error}' client error" do
        stub_request(:get, URI.encode(url_builder.url)).to_return body: JSON.generate({status: error})
        expect { subject.get(url_builder.url) }.to raise_error GoogleDistanceMatrix::ClientError
      end
    end
  end

  describe "request errors" do
    describe "server error" do
      before { stub_request(:get, URI.encode(url_builder.url)).to_return status: [500, "Internal Server Error"] }

      it "wraps the error http response" do
        expect { subject.get(url_builder.url) }.to raise_error GoogleDistanceMatrix::RequestError
      end
    end

    describe "timeout" do
      before { stub_request(:get, URI.encode(url_builder.url)).to_timeout }

      it "wraps the error from Net::HTTP" do
        expect { subject.get(url_builder.url).body }.to raise_error GoogleDistanceMatrix::RequestError
      end
    end
  end
end
