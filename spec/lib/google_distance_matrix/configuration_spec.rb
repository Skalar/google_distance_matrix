require "spec_helper"

describe GoogleDistanceMatrix::Configuration do
  subject { described_class.new }

  describe "Validations" do
    it { should ensure_inclusion_of(:sensor).in_array([true, false]) }

    it { should ensure_inclusion_of(:mode).in_array(["driving", "walking", "bicycling"]) }
    it { should allow_value(nil).for(:mode) }

    it { should ensure_inclusion_of(:avoid).in_array(["tolls", "highways"]) }
    it { should allow_value(nil).for(:avoid) }

    it { should ensure_inclusion_of(:units).in_array(["metric", "imperial"]) }
    it { should allow_value(nil).for(:units) }
  end


  describe "defaults" do
    its(:sensor) { should be_false }
    its(:mode) { should be_nil }
    its(:avoid) { should be_nil }
    its(:units) { should be_nil }
  end

  describe "#to_hash" do
    described_class::ATTRIBUTES.each do |attr|
      it "includes #{attr}" do
        expect(subject.to_hash[attr]).to eq subject.public_send(attr)
      end
    end
  end
end
