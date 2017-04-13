# frozen_string_literal: true

require 'spec_helper'

describe GoogleDistanceMatrix::Matrix do
  let(:origin_1) { GoogleDistanceMatrix::Place.new address: 'Karl Johans gate, Oslo' }
  let(:origin_2) { GoogleDistanceMatrix::Place.new address: 'Askerveien 1, Asker' }

  let(:destination_1) { GoogleDistanceMatrix::Place.new address: 'Drammensveien 1, Oslo' }
  let(:destination_2) { GoogleDistanceMatrix::Place.new address: 'Skjellestadhagen, Heggedal' }

  let(:url_builder) { GoogleDistanceMatrix::UrlBuilder.new subject }
  let(:url) { url_builder.url }

  subject do
    described_class.new(
      origins: [origin_1, origin_2],
      destinations: [destination_1, destination_2]
    )
  end

  describe '#initialize' do
    it 'takes a list of origins' do
      matrix = described_class.new origins: [origin_1, origin_2]
      expect(matrix.origins).to include origin_1, origin_2
    end

    it 'takes a list of destinations' do
      matrix = described_class.new destinations: [destination_1, destination_2]
      expect(matrix.destinations).to include destination_1, destination_2
    end

    it 'has a default configuration' do
      expect(subject.configuration).to be_present
    end
  end

  describe '#configuration' do
    it 'is by default set from default_configuration' do
      config = double
      allow(config).to receive(:dup).and_return config
      expect(GoogleDistanceMatrix).to receive(:default_configuration).and_return config

      expect(described_class.new.configuration).to eq config
    end

    it "has it's own configuration" do
      expect do
        subject.configure { |c| c.mode = !GoogleDistanceMatrix.default_configuration.mode }
      end.to_not change(GoogleDistanceMatrix.default_configuration, :mode)
    end

    it 'has a configurable configuration :-)' do
      expect do
        subject.configure { |c| c.mode = !GoogleDistanceMatrix.default_configuration.mode }
      end.to change(
        subject.configuration, :mode
      ).to !GoogleDistanceMatrix.default_configuration.mode
    end
  end

  %w[origins destinations].each do |attr|
    let(:place) { GoogleDistanceMatrix::Place.new address: 'My street' }

    describe "##{attr}" do
      it 'can receive places' do
        subject.public_send(attr) << place
        expect(subject.public_send(attr)).to include place
      end

      it 'does not same place twice' do
        expect do
          2.times { subject.public_send(attr) << place }
        end.to change(subject.public_send(attr), :length).by 1
      end
    end
  end

  %w[
    route_for
    route_for!
    routes_for
    routes_for!
    shortest_route_by_duration_to
    shortest_route_by_duration_to!
    shortest_route_by_distance_to
    shortest_route_by_distance_to!
    shortest_route_by_duration_in_traffic_to
    shortest_route_by_duration_in_traffic_to!
  ].each do |method|
    it "delegates #{method} to routes_finder" do
      finder = double
      result = double

      allow(subject).to receive(:routes_finder).and_return finder

      expect(finder).to receive(method).and_return result
      expect(subject.public_send(method)).to eq result
    end
  end

  describe 'making API requests', :request_recordings do
    it 'loads correctly API response data in to route objects' do
      stub_request(:get, url).to_return body: recorded_request_for(:success)
      expect(subject.data[0][0].distance_text).to eq '2.0 km'
      expect(subject.data[0][0].distance_in_meters).to eq 2032
      expect(subject.data[0][0].duration_text).to eq '6 mins'
      expect(subject.data[0][0].duration_in_seconds).to eq 367
    end

    it 'loads correctly API response data in to route objects when it includes in traffic data' do
      stub_request(:get, url).to_return body: recorded_request_for(:success_with_in_traffic)
      expect(subject.data[0][0].distance_text).to eq '1.8 km'
      expect(subject.data[0][0].distance_in_meters).to eq 1752
      expect(subject.data[0][0].duration_text).to eq '7 mins'
      expect(subject.data[0][0].duration_in_seconds).to eq 435
      expect(subject.data[0][0].duration_in_traffic_text).to eq '7 mins'
      expect(subject.data[0][0].duration_in_traffic_in_seconds).to eq 405
    end

    context 'no cache' do
      it 'makes multiple requests to same url' do
        stub = stub_request(:get, url).to_return body: recorded_request_for(:success)
        subject.data
        subject.reset!
        subject.data

        expect(stub).to have_been_requested.twice
      end
    end

    context 'with cache' do
      before do
        subject.configure do |config|
          config.cache = ActiveSupport::Cache.lookup_store :memory_store
        end
      end

      it 'makes one requests to same url' do
        stub = stub_request(:get, url).to_return body: recorded_request_for(:success)

        subject.data
        subject.reset!
        subject.data

        expect(stub).to have_been_requested.once
      end

      it 'makes one request when filtered params to same url' do
        was = GoogleDistanceMatrix.default_configuration.filter_parameters_in_logged_url
        GoogleDistanceMatrix.default_configuration.filter_parameters_in_logged_url = ['origins']

        stub = stub_request(:get, url).to_return body: recorded_request_for(:success)

        subject.data
        subject.reset!
        subject.data

        expect(stub).to have_been_requested.once

        GoogleDistanceMatrix.default_configuration.filter_parameters_in_logged_url = was
      end

      it 'clears the cache key on reload' do
        stub = stub_request(:get, url).to_return body: recorded_request_for(:success)
        subject.data
        subject.reload
        subject.data

        expect(stub).to have_been_requested.twice
      end
    end
  end

  describe '#data', :request_recordings do
    context 'success' do
      let!(:api_request_stub) do
        stub_request(:get, url).to_return body: recorded_request_for(:success)
      end

      it "loads from Google's API" do
        subject.data
        expect(api_request_stub).to have_been_requested
      end

      it 'does not load twice' do
        2.times { subject.data }
        expect(api_request_stub).to have_been_requested
      end

      it 'contains one row' do
        expect(subject.data.length).to eq 2
      end

      it 'contains two columns each row' do
        expect(subject.data[0].length).to eq 2
        expect(subject.data[1].length).to eq 2
      end

      it 'assigns correct origin on routes in the data' do
        expect(subject.data[0][0].origin).to eq origin_1
        expect(subject.data[0][1].origin).to eq origin_1

        expect(subject.data[1][0].origin).to eq origin_2
        expect(subject.data[1][1].origin).to eq origin_2
      end

      it 'assigns correct destination on routes in the data' do
        expect(subject.data[0][0].destination).to eq destination_1
        expect(subject.data[0][1].destination).to eq destination_2

        expect(subject.data[1][0].destination).to eq destination_1
        expect(subject.data[1][1].destination).to eq destination_2
      end
    end

    context 'some elements is not OK' do
      let!(:api_request_stub) do
        stub_request(:get, url).to_return body: recorded_request_for(:zero_results)
      end

      it "loads from Google's API" do
        subject.data
        expect(api_request_stub).to have_been_requested
      end

      it 'adds loaded route with errors correctly' do
        route = subject.data[0][1]

        expect(route.status).to eq 'zero_results'
        expect(route.duration_in_seconds).to be_nil
      end
    end
  end

  describe '#reload' do
    before do
      allow(subject).to receive(:load_matrix) { ['loaded'] }
      subject.data.clear
    end

    it "reloads matrix' data from the API" do
      expect do
        subject.reload
      end.to change(subject, :data).from([]).to ['loaded']
    end

    it 'is chainable' do
      expect(subject.reload.data).to eq ['loaded']
    end
  end
end
