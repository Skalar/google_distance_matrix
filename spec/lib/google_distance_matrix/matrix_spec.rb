require "spec_helper"

describe GoogleDistanceMatrix::Matrix do
  subject { described_class.new }

  let(:place) { GoogleDistanceMatrix::Place.new address: "Karl Johans gate, Oslo" }

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
