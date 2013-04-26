require "spec_helper"

describe GoogleDistanceMatrix::RoutesFinder, :request_recordings do
  let(:origin_1) { GoogleDistanceMatrix::Place.new address: "Karl Johans gate, Oslo" }
  let(:origin_2) { GoogleDistanceMatrix::Place.new address: "Askerveien 1, Asker" }

  let(:destination_1) { GoogleDistanceMatrix::Place.new address: "Drammensveien 1, Oslo" }
  let(:destination_2) { GoogleDistanceMatrix::Place.new address: "Skjellestadhagen, Heggedal" }

  let(:url_builder) { GoogleDistanceMatrix::UrlBuilder.new matrix }
  let(:encoded_url) { URI.encode url_builder.url }

  let(:matrix) do
    GoogleDistanceMatrix::Matrix.new(
      origins: [origin_1, origin_2],
      destinations: [destination_1, destination_2]
    )
  end

  subject { described_class.new matrix }



  describe "#find" do
    let!(:api_request_stub) { stub_request(:get, encoded_url).to_return body: recorded_request_for(:success) }

    it "fails if no origin nor destination is given" do
      expect { subject.find }. to raise_error ArgumentError
    end

    it "returns routes given an origin" do
      routes = subject.find origin: origin_1

      expect(routes.length).to eq 2
      expect(routes.map(&:origin).all? { |o| o == origin_1 }).to be true
    end

    it "fails with argument error if matrix does not contain given origin" do
      expect { subject.find origin: destination_1}. to raise_error ArgumentError
    end


    it "returns routes given an destination" do
      routes = subject.find destination: destination_2

      expect(routes.length).to eq 2
      expect(routes.map(&:destination).all? { |d| d == destination_2 }).to be true
    end

    it "fails with argument error if matrix does not contain given destination" do
      expect { subject.find destination: origin_1}. to raise_error ArgumentError
    end
  end
end
