require "spec_helper"

describe GoogleDistanceMatrix::Matrix do
  let(:place) { GoogleDistanceMatrix::Place.new address: "Karl Johans gate, Oslo" }

  subject { described_class.new }

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

    it "is not loaded to begin with" do
      expect(subject).to_not be_loaded
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
end
