# frozen_string_literal: true

require 'spec_helper'

describe GoogleDistanceMatrix::ClientCache do
  let(:config) { GoogleDistanceMatrix::Configuration.new }
  let(:url) { 'http://www.example.com' }
  let(:options) { { hello: :options, configuration: config } }

  let(:client) { double get: 'data' }
  let(:cache) { double }

  subject { described_class.new client, cache }

  # rubocop:disable Metrics/LineLength
  describe '::key' do
    it 'returns a digest of given URL' do
      key = described_class.key 'some url with secret parts', config
      expect(key).to eq 'e90595434d4e321da6b01d2b99d77419ddaa8861d83c5971c4a119ee76bb80a7003915cc16e6966615f205b4a1d5411bb5d4a0d907f611b3fe4cc8d9049f4f9c'
    end
  end

  describe '#get' do
    it 'returns from cache if it hits' do
      expect(cache)
        .to receive(:fetch)
        .with('2f7d4c4d8a51afd0f9efb9edfda07591591cccc3704130328ad323d3cb5bf7ff19df5e895b402c99217d27d5f4547618094d47069c9ba58370ed8e26cc1de114')
        .and_return 'cached-data'

      expect(subject.get(url, options)).to eq 'cached-data'
    end
    # rubocop:enable Metrics/LineLength

    it 'asks client when cache miss' do
      expect(client).to receive(:get).with(url, options).and_return 'api-data'
      expect(cache).to receive(:fetch) { |&block| block.call }

      expect(subject.get(url, options)).to eq 'api-data'
    end
  end
end
