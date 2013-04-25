require "spec_helper"

describe GoogleDistanceMatrix::Matrix, :request_recordings do
  let(:origin_1) { GoogleDistanceMatrix::Place.new address: "Karl Johans gate, Oslo" }
  let(:origin_2) { GoogleDistanceMatrix::Place.new address: "Askerveien 1, Asker" }

  let(:destination_1) { GoogleDistanceMatrix::Place.new address: "Drammensveien 1, Oslo" }
  let(:destination_2) { GoogleDistanceMatrix::Place.new address: "Skjellestadhagen, Heggedal" }

  let(:url_builder) { GoogleDistanceMatrix::UrlBuilder.new subject }
  let(:encoded_url) { URI.encode url_builder.url }

  subject do
    described_class.new(
      origins: [origin_1, origin_2],
      destinations: [destination_1, destination_2]
    )
  end

  describe "#initialize" do
    it "takes a list of origins" do
      matrix = described_class.new origins: [1, 2]
      expect(matrix.origins).to include 1, 2
    end

    it "takes a list of destinations" do
      matrix = described_class.new destinations: [3, 4]
      expect(matrix.destinations).to include 3, 4
    end

    it "has a default configuration" do
      expect(subject.configuration).to be_present
    end
  end

  describe "#configuration" do
    it "is by default set from default_configuration" do
      config = mock
      config.stub(:dup).and_return config
      GoogleDistanceMatrix.should_receive(:default_configuration).and_return config

      expect(described_class.new.configuration).to eq config
    end

    it "has it's own configuration" do
      expect {
        subject.configure { |c| c.sensor = !GoogleDistanceMatrix.default_configuration.sensor }
      }.to_not change(GoogleDistanceMatrix.default_configuration, :sensor)
    end

    it "has a configurable configuration :-)" do
      expect {
        subject.configure { |c| c.sensor = !GoogleDistanceMatrix.default_configuration.sensor }
      }.to change(subject.configuration, :sensor).to !GoogleDistanceMatrix.default_configuration.sensor
    end
  end

  %w[origins destinations].each do |attr|
    let(:place) { GoogleDistanceMatrix::Place.new address: "My street" }

    describe "##{attr}" do
      it "can receive places" do
        subject.public_send(attr) << place
        expect(subject.public_send(attr)).to include place
      end

      it "does not same place twice" do
        expect {
          2.times { subject.public_send(attr) << place }
        }.to change(subject.public_send(attr), :length).by 1
      end
    end
  end

  describe "#routes_for" do
    let!(:api_request_stub) { stub_request(:get, encoded_url).to_return body: recorded_request_for(:success) }

    it "fails if no origin nor destination is given" do
      expect { subject.routes_for }. to raise_error ArgumentError
    end

    it "returns routes given an origin" do
      routes = subject.routes_for origin: origin_1

      expect(routes.length).to eq 2
      expect(routes.map(&:origin).all? { |o| o == origin_1 }).to be true
    end

    it "fails with argument error if matrix does not contain given origin" do
      expect { subject.routes_for origin: destination_1}. to raise_error ArgumentError
    end


    it "returns routes given an destination" do
      routes = subject.routes_for destination: destination_2

      expect(routes.length).to eq 2
      expect(routes.map(&:destination).all? { |d| d == destination_2 }).to be true
    end

    it "fails with argument error if matrix does not contain given destination" do
      expect { subject.routes_for destination: origin_1}. to raise_error ArgumentError
    end

    it "finds route for given origin and destination" do
      routes = subject.routes_for origin: origin_1, destination: destination_2

      expect(routes.length).to eq 1

      route = routes.first

      expect(route.origin).to eq origin_1
      expect(route.destination).to eq destination_2
    end
  end

  describe "#route_for" do
    let!(:api_request_stub) { stub_request(:get, encoded_url).to_return body: recorded_request_for(:success) }

    it "finds route for given origin and destination" do
      route = subject.route_for origin: origin_1, destination: destination_2

      expect(route.origin).to eq origin_1
      expect(route.destination).to eq destination_2
    end

    it "fails with argument error if origin is missing" do
      expect { subject.route_for destination: destination_2 }.to raise_error ArgumentError
    end

    it "fails with argument error if destination is missing" do
      expect { subject.route_for origin: origin_1 }.to raise_error ArgumentError
    end
  end


  describe "#data" do
    let!(:api_request_stub) { stub_request(:get, encoded_url).to_return body: recorded_request_for(:success) }

    it "loads from Google's API" do
      subject.data
      api_request_stub.should have_been_requested
    end

    it "does not load twice" do
      2.times { subject.data }
      api_request_stub.should have_been_requested
    end

    it "contains one row" do
      expect(subject.data.length).to eq 2
    end

    it "contains two columns each row" do
      expect(subject.data[0].length).to eq 2
      expect(subject.data[1].length).to eq 2
    end

    it "assigns correct origin on routes in the data" do
      expect(subject.data[0][0].origin).to eq origin_1
      expect(subject.data[0][1].origin).to eq origin_1

      expect(subject.data[1][0].origin).to eq origin_2
      expect(subject.data[1][1].origin).to eq origin_2
    end

    it "assigns correct destination on routes in the data" do
      expect(subject.data[0][0].destination).to eq destination_1
      expect(subject.data[0][1].destination).to eq destination_2

      expect(subject.data[1][0].destination).to eq destination_1
      expect(subject.data[1][1].destination).to eq destination_2
    end
  end
end
