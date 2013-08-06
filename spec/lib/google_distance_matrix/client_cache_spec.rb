require "spec_helper"

describe GoogleDistanceMatrix::ClientCache do
  let(:url) { "http://www.example.com" }
  let(:options) { {hello: :options} }

  let(:client) { mock get: "data" }
  let(:cache) { mock }

  subject { described_class.new client, cache }

  describe "#get" do
    it "returns from cache if it hits" do
      cache.should_receive(:fetch).with(url).and_return "cached-data"
      expect(subject.get(url, options)).to eq "cached-data"
    end

    it "asks client when cache miss" do
      client.should_receive(:get).with(url, options).and_return "api-data"
      cache.should_receive(:fetch) { |&block| block.call }

      expect(subject.get(url, options)).to eq "api-data"
    end
  end
end
