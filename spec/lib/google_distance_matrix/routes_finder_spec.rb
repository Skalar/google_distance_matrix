# frozen_string_literal: true

require 'spec_helper'

describe GoogleDistanceMatrix::RoutesFinder, :request_recordings do
  let(:origin_1_attributes) { { address: 'Karl Johans gate, Oslo' } }
  let(:origin_1) { GoogleDistanceMatrix::Place.new origin_1_attributes }
  let(:origin_2) { GoogleDistanceMatrix::Place.new address: 'Askerveien 1, Asker' }

  let(:destination_1) { GoogleDistanceMatrix::Place.new address: 'Drammensveien 1, Oslo' }

  let(:destination_2_built_from) { double address: 'Skjellestadhagen, Heggedal' }
  let(:destination_2) { GoogleDistanceMatrix::Place.new destination_2_built_from }

  let(:url_builder) { GoogleDistanceMatrix::UrlBuilder.new matrix }
  let(:url) { url_builder.sensitive_url }

  let(:matrix) do
    GoogleDistanceMatrix::Matrix.new(
      origins: [origin_1, origin_2],
      destinations: [destination_1, destination_2]
    )
  end

  subject { described_class.new matrix }

  context 'success, with traffic data' do
    before do
      matrix.configure do |c|
        c.departure_time = 'now'
      end
    end

    let!(:api_request_stub) do
      stub_request(:get, url).to_return body: recorded_request_for(:success_with_in_traffic)
    end

    describe '#shortest_route_by_duration_in_traffic_to' do
      it 'returns route representing shortest duration to given origin' do
        expect(subject.shortest_route_by_duration_in_traffic_to(origin_1)).to eq matrix.data[0][0]
      end

      it 'returns route representing shortest duration to given destination' do
        expect(subject.shortest_route_by_duration_in_traffic_to(destination_2))
          .to eq matrix.data[1][1]
      end
    end

    describe '#shortest_route_by_duration_in_traffic_to!' do
      it 'returns the same as shortest_route_by_duration_in_traffic_to' do
        expect(subject.shortest_route_by_duration_in_traffic_to!(origin_1))
          .to eq subject.shortest_route_by_duration_in_traffic_to(origin_1)
      end
    end
  end

  context 'success, without in traffic data' do
    let!(:api_request_stub) do
      stub_request(:get, url).to_return body: recorded_request_for(:success)
    end

    describe '#routes_for' do
      it 'fails if given place does not exist' do
        expect { subject.routes_for 'foo' }.to raise_error ArgumentError
      end

      it 'returns routes for given origin' do
        routes = subject.routes_for origin_1

        expect(routes.length).to eq 2
        expect(routes.map(&:origin).all? { |o| o == origin_1 }).to be true
      end

      it 'still returns routes for origin if it has same address but different object_id' do
        routes = subject.routes_for GoogleDistanceMatrix::Place.new origin_1_attributes

        expect(routes.length).to eq 2
        expect(routes.map(&:origin).all? { |o| o == origin_1 }).to be true
      end

      it 'returns routes for given destination' do
        routes = subject.routes_for destination_2

        expect(routes.length).to eq 2
        expect(routes.map(&:destination).all? { |d| d == destination_2 }).to be true
      end

      it 'returns routes for given object a place was built from' do
        routes = subject.routes_for destination_2_built_from

        expect(routes.length).to eq 2
        expect(routes.map(&:destination).all? { |d| d == destination_2 }).to be true
      end

      context 'place built from hash' do
        let(:destination_2_built_from) { { address: 'Skjellestadhagen, Heggedal' } }

        it 'returns routes for given hash a place was built from' do
          routes = subject.routes_for destination_2_built_from

          expect(routes.length).to eq 2
          expect(routes.map(&:destination).all? { |d| d == destination_2 }).to be true
        end
      end
    end

    describe '#routes_for!' do
      it 'returns the same as routes_for' do
        expect(subject.routes_for!(origin_1)).to eq subject.routes_for(origin_1)
      end
    end

    describe '#route_for' do
      it 'returns route' do
        route = subject.route_for(origin: origin_1, destination: destination_1)
        expect(route.origin).to eq origin_1
        expect(route.destination).to eq destination_1
      end

      it 'returns route when you give it the object a place was built from' do
        route = subject.route_for(origin: origin_1, destination: destination_2_built_from)
        expect(route.origin).to eq origin_1
        expect(route.destination).to eq destination_2
      end

      context 'place built from hash' do
        let(:destination_2_built_from) { { address: 'Skjellestadhagen, Heggedal' } }

        it 'returns route when you give it the hash the place was built from' do
          route = subject.route_for(origin: origin_1, destination: destination_2_built_from)
          expect(route.origin).to eq origin_1
          expect(route.destination).to eq destination_2
        end
      end

      it 'fails with argument error if origin is missing' do
        expect { subject.route_for destination: destination_2 }.to raise_error ArgumentError
      end

      it 'fails with argument error if destination is missing' do
        expect { subject.route_for origin: origin_1 }.to raise_error ArgumentError
      end

      it 'fails with argument error if object is neither place nor something it was built from' do
        expect do
          subject.route_for origin: origin_1, destination: double
        end.to raise_error ArgumentError
      end
    end

    describe '#route_for!' do
      it 'returns the same as route_for' do
        route = subject.route_for(origin: origin_1, destination: destination_1)
        route_bang = subject.route_for!(origin: origin_1, destination: destination_1)

        expect(route).to eq route_bang
      end
    end

    describe '#shortest_route_by_distance_to' do
      it 'returns route representing shortest distance to given origin' do
        expect(subject.shortest_route_by_distance_to(origin_1)).to eq matrix.data[0][0]
      end

      it 'returns route representing shortest distance to given destination' do
        expect(subject.shortest_route_by_distance_to(destination_2)).to eq matrix.data[1][1]
      end
    end

    describe '#shortest_route_by_distance_to!' do
      it 'returns the same as shortest_route_by_distance_to' do
        expect(subject.shortest_route_by_distance_to!(origin_1))
          .to eq subject.shortest_route_by_distance_to(origin_1)
      end
    end

    describe '#shortest_route_by_duration_to' do
      it 'returns route representing shortest duration to given origin' do
        expect(subject.shortest_route_by_duration_to(origin_1)).to eq matrix.data[0][0]
      end

      it 'returns route representing shortest duration to given destination' do
        expect(subject.shortest_route_by_duration_to(destination_2)).to eq matrix.data[1][1]
      end
    end

    describe '#shortest_route_by_duration_to!' do
      it 'returns the same as shortest_route_by_duration_to' do
        expect(subject.shortest_route_by_duration_to!(origin_1))
          .to eq subject.shortest_route_by_duration_to(origin_1)
      end
    end

    describe '#shortest_route_by_duration_in_traffic_to' do
      it 'returns route representing shortest duration to given origin' do
        expect do
          subject.shortest_route_by_duration_in_traffic_to(origin_1)
        end.to raise_error GoogleDistanceMatrix::InvalidQuery
      end
    end

    describe '#shortest_route_by_duration_in_traffic_to!' do
      it 'returns the same as shortest_route_by_duration_in_traffic_to' do
        expect do
          subject.shortest_route_by_duration_in_traffic_to!(origin_1)
        end.to raise_error GoogleDistanceMatrix::InvalidQuery
      end
    end
  end

  context 'routes mssing data' do
    let!(:api_request_stub) do
      stub_request(:get, url).to_return body: recorded_request_for(:zero_results)
    end

    describe '#routes_for' do
      it 'returns routes for given origin' do
        routes = subject.routes_for origin_1

        expect(routes.length).to eq 2
        expect(routes.map(&:origin).all? { |o| o == origin_1 }).to be true
      end
    end

    describe '#routes_for!' do
      it 'fails upon any non-ok route' do
        expect do
          subject.routes_for! origin_1
        end.to raise_error GoogleDistanceMatrix::InvalidRoute
      end
    end

    describe '#route_for' do
      it 'returns route' do
        route = subject.route_for origin: origin_1, destination: destination_2
        expect(route.origin).to eq origin_1
        expect(route.destination).to eq destination_2
      end
    end

    describe '#route_for!' do
      it 'fails upon non-ok route' do
        expect do
          subject.route_for! origin: origin_1, destination: destination_2
        end.to raise_error GoogleDistanceMatrix::InvalidRoute
      end
    end

    describe '#shortest_route_by_distance_to' do
      it 'returns route representing shortest distance to given origin' do
        expect(subject.shortest_route_by_distance_to(origin_1)).to eq matrix.data[0][0]
      end
    end

    describe '#shortest_route_by_distance_to!' do
      it 'fails upon non-ok route' do
        expect { subject.shortest_route_by_distance_to!(origin_1) }
          .to raise_error GoogleDistanceMatrix::InvalidRoute
      end
    end

    describe '#shortest_route_by_duration_to' do
      it 'returns route representing shortest distance to given origin' do
        expect(subject.shortest_route_by_duration_to(origin_1)).to eq matrix.data[0][0]
      end
    end

    describe '#shortest_route_by_duration_to!' do
      it 'fails upon non-ok route' do
        expect { subject.shortest_route_by_duration_to!(origin_1) }
          .to raise_error GoogleDistanceMatrix::InvalidRoute
      end
    end
  end
end
