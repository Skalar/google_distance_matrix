require "spec_helper"

describe GoogleDistanceMatrix::Configuration do
  include Shoulda::Matchers::ActiveModel

  subject { described_class.new }

  describe "Validations" do
    describe "sensor" do
      it "is valid with true" do
        subject.sensor = true
        subject.valid?
        expect(subject.errors[:sensor].length).to eq 0
      end

      it "is valid with false" do
        subject.sensor = false
        subject.valid?
        expect(subject.errors[:sensor].length).to eq 0
      end

      it "is invalid with 'foo'" do
        subject.sensor = 'foo'
        subject.valid?
        expect(subject.errors[:sensor].length).to eq 1
      end
    end

    it { should validate_inclusion_of(:mode).in_array(["driving", "walking", "bicycling"]) }
    it { should allow_value(nil).for(:mode) }

    it { should validate_inclusion_of(:avoid).in_array(["tolls", "highways"]) }
    it { should allow_value(nil).for(:avoid) }

    it { should validate_inclusion_of(:units).in_array(["metric", "imperial"]) }
    it { should allow_value(nil).for(:units) }

    it { should validate_inclusion_of(:protocol).in_array(["http", "https"]) }
  end


  describe "defaults" do
    it { expect(subject.sensor).to eq false }
    it { expect(subject.mode).to eq "driving" }
    it { expect(subject.avoid).to be_nil }
    it { expect(subject.units).to eq "metric" }
    it { expect(subject.lat_lng_scale).to eq 5 }
    it { expect(subject.protocol).to eq 'http' }
    it { expect(subject.language).to be_nil }

    it { expect(subject.google_business_api_client_id).to be_nil }
    it { expect(subject.google_business_api_private_key).to be_nil }

    it { expect(subject.logger).to be_nil }
    it { expect(subject.cache).to be_nil }
  end


  describe "#to_param" do
    described_class::ATTRIBUTES.each do |attr|
      it "includes #{attr}" do
        subject[attr] = "foo"
        expect(subject.to_param[attr]).to eq subject.public_send(attr)
      end

      it "does not include #{attr} when it is blank" do
        subject[attr] = nil
        expect(subject.to_param.with_indifferent_access).to_not have_key attr
      end
    end

    described_class::API_DEFAULTS.each_pair do |attr, default_value|
      it "does not include #{attr} when it equals what is default for API" do
        subject[attr] = default_value

        expect(subject.to_param.with_indifferent_access).to_not have_key attr
      end
    end

    it "includes client if google_business_api_client_id has been set" do
      subject.google_business_api_client_id = "123"
      expect(subject.to_param['client']).to eq "123"
    end
  end
end
