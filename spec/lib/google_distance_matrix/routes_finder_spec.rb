require "spec_helper"

describe GoogleDistanceMatrix::RoutesFinder, :request_recordings do
  let(:origin_1) { GoogleDistanceMatrix::Place.new address: "Karl Johans gate, Oslo" }
  let(:origin_2) { GoogleDistanceMatrix::Place.new address: "Askerveien 1, Asker" }

  let(:destination_1) { GoogleDistanceMatrix::Place.new address: "Drammensveien 1, Oslo" }

  let(:destination_2_built_from) { mock address: "Skjellestadhagen, Heggedal" }
  let(:destination_2) { GoogleDistanceMatrix::Place.new destination_2_built_from }

  let(:url_builder) { GoogleDistanceMatrix::UrlBuilder.new matrix }
  let(:encoded_url) { URI.encode url_builder.url }

  let(:matrix) do
    GoogleDistanceMatrix::Matrix.new(
      origins: [origin_1, origin_2],
      destinations: [destination_1, destination_2]
    )
  end

  subject { described_class.new matrix }

  let!(:api_request_stub) { stub_request(:get, encoded_url).to_return body: recorded_request_for(:success) }


  describe "#routes_for" do
    it "fails if given place does not exist" do
      expect { subject.routes_for "foo" }.to raise_error ArgumentError
    end

    it "returns routes for given origin" do
      routes = subject.routes_for origin_1

      expect(routes.length).to eq 2
      expect(routes.map(&:origin).all? { |o| o == origin_1 }).to be true
    end

    it "returns routes for given destination" do
      routes = subject.routes_for destination_2

      expect(routes.length).to eq 2
      expect(routes.map(&:destination).all? { |d| d == destination_2 }).to be true
    end

    it "returns routes for given object a place was built from" do
      routes = subject.routes_for destination_2_built_from

      expect(routes.length).to eq 2
      expect(routes.map(&:destination).all? { |d| d == destination_2 }).to be true
    end
  end

  describe "#route_for" do
    it "returns route" do
      route = subject.route_for(origin: origin_1, destination: destination_1)
      expect(route.origin).to eq origin_1
      expect(route.destination).to eq destination_1
    end

    it "returns route when you give it the object a place was built from" do
      route = subject.route_for(origin: origin_1, destination: destination_2_built_from)
      expect(route.origin).to eq origin_1
      expect(route.destination).to eq destination_2
    end

    it "fails with argument error if origin is missing" do
      expect { subject.route_for destination: destination_2 }.to raise_error ArgumentError
    end

    it "fails with argument error if destination is missing" do
      expect { subject.route_for origin: origin_1 }.to raise_error ArgumentError
    end

    it "fails with argument error if sent in object is neither place nor something it was built from" do
      expect { subject.route_for origin: origin_1, destination: mock }.to raise_error ArgumentError
    end
  end


  describe "#shortest_route_by_distance_to" do
    it "returns route representing shortest distance to given origin" do
      expect(subject.shortest_route_by_distance_to(origin_1)).to eq matrix.data[0][0]
    end

    it "returns route representing shortest distance to given destination" do
      expect(subject.shortest_route_by_distance_to(destination_2)).to eq matrix.data[1][1]
    end
  end

  describe "#shortest_route_by_duration_to" do
    it "returns route representing shortest duration to given origin" do
      expect(subject.shortest_route_by_duration_to(origin_1)).to eq matrix.data[0][0]
    end

    it "returns route representing shortest duration to given destination" do
      expect(subject.shortest_route_by_duration_to(destination_2)).to eq matrix.data[1][1]
    end
  end
end
