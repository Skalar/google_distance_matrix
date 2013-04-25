require "spec_helper"

describe GoogleDistanceMatrix::Configuration do
  subject { described_class.new }

  describe "defaults" do
    its(:sensor) { should be_false }
  end

  describe "#to_hash" do
    described_class::ATTRIBUTES.each do |attr|
      it "includes #{attr}" do
        expect(subject.to_hash[attr]).to eq subject.public_send(attr)
      end
    end
  end
end
