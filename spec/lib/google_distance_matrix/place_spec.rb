require "spec_helper"

describe GoogleDistanceMatrix::Place do
  let(:address) { "Karl Johans gate, Oslo" }
  let(:lat) { 1.4 }
  let(:lng) { 2.2 }

  describe "#initialize" do
    it "builds with an address" do
      place = described_class.new(address: address)
      expect(place.address).to eq address
    end

    it "builds with lat lng" do
      place = described_class.new(lat: lat, lng: lng)
      expect(place.lat).to eq lat
      expect(place.lng).to eq lng
    end

    it "builds with an object responding to lat and lng" do
      point = mock lat: 1, lng: 2
      place = described_class.new(point)

      expect(place.lat).to eq point.lat
      expect(place.lng).to eq point.lng
    end


    it "keeps a record of the object it built itself from" do
      point = mock lat: 1, lng: 2
      place = described_class.new(point)

      expect(place.extracted_attributes_from).to eq point
    end
    it "builds with an object responding to address" do
      object = mock address: address
      place = described_class.new(object)

      expect(place.address).to eq object.address
    end

    it "builds with an object responding to lat, lng and address" do
      object = mock lat: 1, lng:2, address: address
      place = described_class.new(object)

      expect(place.lat).to eq object.lat
      expect(place.lng).to eq object.lng
      expect(place.address).to be_nil
    end

    it "fails if no valid attributes given" do
      expect { described_class.new }.to raise_error ArgumentError
      expect { described_class.new(lat: lat) }.to raise_error ArgumentError
      expect { described_class.new(lng: lng) }.to raise_error ArgumentError
    end

    it "fails if both address, lat ang lng is given" do
      expect { described_class.new(address: address, lat: lat, lng: lng) }.to raise_error ArgumentError
    end
  end

  describe "#to_param" do
    context "with address" do
      subject { described_class.new address: address }

      its(:to_param) { should eq address }
    end

    context "with lat lng" do
      subject { described_class.new lng: lng, lat: lat }

      its(:to_param) { should eq "#{lat},#{lng}" }
    end
  end

  describe "#equal?" do
    it "is considered equal when address is the same" do
      expect(described_class.new(address: address)).to be_eql described_class.new(address: address)
    end

    it "is considered equal when lat and lng are the same" do
      expect(described_class.new(lat: lat, lng: lng)).to be_eql described_class.new(lat: lat, lng: lng)
    end

    it "is not considered equal when address differs" do
      expect(described_class.new(address: address)).to_not be_eql described_class.new(address: address + ", Norway")
    end

    it "is not considered equal when lat or lng differs" do
      expect(described_class.new(lat: lat, lng: lng)).to_not be_eql described_class.new(lat: lat, lng: lng + 1)
    end
  end
end
