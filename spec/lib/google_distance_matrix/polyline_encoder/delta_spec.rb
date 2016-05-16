require 'spec_helper'

module GoogleDistanceMatrix
  describe PolylineEncoder::Delta do
    it 'calculates deltas correctly' do
      deltas = described_class.new([[38.5, -120.2], [40.7, -120.95], [43.252, -126.453]]).deltas

      expect(deltas).to eq [
        3850000,  -12020000,
        220000,   -75000,
        255200,   -550300
      ]
    end
  end
end
