# frozen_string_literal: true

require 'spec_helper'

describe GoogleDistanceMatrix::Places do
  let(:values) { [{ address: 'one' }, { address: 'two' }, { address: 'three' }] }
  let(:places) { values.map { |v| GoogleDistanceMatrix::Place.new v } }

  let(:place_4) { GoogleDistanceMatrix::Place.new address: 'four' }
  let(:place_5) { GoogleDistanceMatrix::Place.new address: 'five' }
  let(:place_6) { GoogleDistanceMatrix::Place.new address: 'six' }

  subject { described_class.new places }

  it { should include(*places) }
  it { should_not include 5 }

  %w[<< push unshift].each do |attr|
    describe attr.to_s do
      it 'adds value' do
        expect do
          subject.public_send attr, place_4
        end.to change { subject.include? place_4 }.to true
      end

      it 'keeps uniq values' do
        subject.public_send attr, place_4

        expect do
          subject.public_send attr, place_4
        end.to_not change subject, :length
      end

      it 'is chanable' do
        subject.public_send(attr, place_5).public_send(attr, place_6)

        expect(subject).to include place_5, place_6
      end

      it 'wraps values in a Place' do
        subject.public_send attr, address: 'four'

        expect(subject.all? { |place| place.is_a? GoogleDistanceMatrix::Place }).to be true
        expect(subject.any? { |place| place.address == 'four' }).to be true
      end
    end
  end

  %w[push unshift].each do |attr|
    describe attr.to_s do
      it 'adds multiple values at once' do
        subject.public_send attr, place_4, place_5
        expect(subject).to include place_4, place_5
      end
    end
  end

  describe '#concat' do
    let(:places_2) { [place_4, place_5, place_6] }

    it 'adds the given array' do
      subject.concat places_2
      expect(subject).to include(*places_2)
    end

    it 'keeps values uniq' do
      subject.concat places_2

      expect do
        subject.concat places_2
      end.to_not change subject, :length
    end

    it 'returns self' do
      expect(subject.concat(places_2)).to eq subject
    end
  end
end
