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

    it { should ensure_inclusion_of(:protocol).in_array(["http", "https"]) }
  end


  describe "defaults" do
    its(:sensor) { should be_false }
    its(:mode) { should eq "driving" }
    its(:avoid) { should be_nil }
    its(:units) { should eq "metric" }
    its(:lat_lng_scale) { should eq 5 }
    its(:protocol) { should eq "http" }

    its(:google_business_api_client_id) { should be_nil }
    its(:google_business_api_private_key) { should be_nil }

    its(:logger) { should be_nil }
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
