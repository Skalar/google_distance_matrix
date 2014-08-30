require "spec_helper"

describe GoogleDistanceMatrix::UrlBuilder do
  let(:delimiter) { described_class::DELIMITER }
  let(:comma) { CGI.escape "," }

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

  describe "#initialize" do
    it "has a matrix" do
      expect(described_class.new(matrix).matrix).to eq matrix
    end

    it "fails if matrix is invalid" do
      expect {
        described_class.new GoogleDistanceMatrix::Matrix.new
      }.to raise_error GoogleDistanceMatrix::InvalidMatrix
    end

    it "fails if matrix's configuration is invalid" do
      expect {
        matrix.configure { |c| c.sensor = nil }
        described_class.new matrix
      }.to raise_error GoogleDistanceMatrix::InvalidMatrix
    end
  end


  describe "#url" do
    it "fails if the url is more than 2048 characters" do
      long_string = ""
      2049.times { long_string << "a" }

      allow(subject).to receive(:get_params_string).and_return long_string

      expect { subject.url }.to raise_error GoogleDistanceMatrix::MatrixUrlTooLong
    end

    it "starts with the base URL" do
      expect(subject.url).to start_with "http://" + described_class::BASE_URL
    end

    it "has a configurable protocol" do
      matrix.configure { |c| c.protocol = "https" }
      expect(subject.url).to start_with "https://"
    end

    it "includes origins" do
      expect(subject.url).to include "origins=address_origin_1#{delimiter}address_origin_2"
    end

    it "includes destinations" do
      expect(subject.url).to include "destinations=1#{comma}11#{delimiter}2#{comma}22"
    end

    describe "lat lng scale" do
      let(:destination_1) { GoogleDistanceMatrix::Place.new lat: 10.123456789, lng: "10.987654321" }

      it "rounds lat and lng" do
        subject.matrix.configure { |c| c.lat_lng_scale = 5 }

        expect(subject.url).to include "destinations=10.12346#{comma}10.98765"
      end
    end

    describe "configuration" do
      it "includes sensor" do
        expect(subject.url).to include "sensor=#{matrix.configuration.sensor}"
      end

      context "with google business client id and private key set" do
        before do
          matrix.configure do |config|
            config.google_business_api_client_id = "123"
            config.google_business_api_private_key = "c2VjcmV0"
          end
        end

        it "includes client" do
          expect(subject.url).to include "client=#{matrix.configuration.google_business_api_client_id}"
        end

        it "has signature" do
          expect(subject.url).to include "signature=R6dKSHc7EZ7uzmpXKngJCX9i2_E="
        end
      end
    end
  end
end
