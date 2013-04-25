require "spec_helper"

describe GoogleDistanceMatrix::Matrix do
  let(:origin_1) { GoogleDistanceMatrix::Place.new address: "Karl Johans gate, Oslo" }
  let(:origin_2) { GoogleDistanceMatrix::Place.new address: "Askerveien 1, Asker" }

  let(:destination_1) { GoogleDistanceMatrix::Place.new address: "Drammensveien 1, Oslo" }
  let(:destination_2) { GoogleDistanceMatrix::Place.new address: "Skjellestadhagen, Heggedal" }

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


  describe "#matrix", :request_recordings do
    let(:url_builder) { GoogleDistanceMatrix::UrlBuilder.new subject }
    let!(:api_request_stub) do
      stub_request(:get, URI.encode(url_builder.url)).to_return body: recorded_request_for(:success)
    end

    it "loads from Google's API" do
      subject.matrix
      api_request_stub.should have_been_requested
    end

    it "does not load twice" do
      2.times { subject.matrix }
      api_request_stub.should have_been_requested
    end

    it "contains one row" do
      expect(subject.matrix.length).to eq 2
    end

    it "contains two columns each row" do
      expect(subject.matrix[0].length).to eq 2
      expect(subject.matrix[1].length).to eq 2
    end
  end
end
