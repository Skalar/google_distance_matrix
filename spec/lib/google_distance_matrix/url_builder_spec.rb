require "spec_helper"

describe GoogleDistanceMatrix::UrlBuilder do
  let(:origin_1) { GoogleDistanceMatrix::Place.new address: "address_origin_1" }
  let(:origin_2) { GoogleDistanceMatrix::Place.new address: "address_origin_2" }

  let(:destination_1) { GoogleDistanceMatrix::Place.new lat: 1, lng: 11 }
  let(:destination_2) { GoogleDistanceMatrix::Place.new lat: 2, lng: 22 }

  let(:origins) { [origin_1, origin_2] }
  let(:destinations) { [destination_1, destination_2] }

  let(:matrix) do
    GoogleDistanceMatrix::Matrix.new(
      origins: origins,
      destinations: destinations
    )
  end

  subject { described_class.new matrix }

  its(:matrix) { should eq matrix }


  describe "#url" do
    it "fails if the url is more than 2048 characters" do
      long_string = ""
      2049.times { long_string << "a" }

      subject.stub(:get_params_string).and_return long_string

      expect { subject.url }.to raise_error GoogleDistanceMatrix::MatrixUrlTooLong
    end

    it "starts with the base URL" do
      expect(subject.url).to start_with described_class::BASE_URL
    end

    it "includes origins" do
      expect(subject.url).to include "origins=address_origin_1|address_origin_2"
    end

    it "includes destinations" do
      expect(subject.url).to include "destinations=1,11|2,22"
    end
  end
end
