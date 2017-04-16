# frozen_string_literal: true

require 'spec_helper'

module GoogleDistanceMatrix
  describe PolylineEncoder::Delta do
    it 'calculates deltas correctly' do
      deltas = subject.deltas_rounded [[38.5, -120.2], [40.7, -120.95], [43.252, -126.453]]

      expect(deltas).to eq [
        3_850_000, -12_020_000,
        220_000,   -75_000,
        255_200,   -550_300
      ]
    end
  end
end
