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
  end

  %w[origins destinations].each do |attr|
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
