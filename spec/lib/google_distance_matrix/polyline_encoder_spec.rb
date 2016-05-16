require 'spec_helper'

module GoogleDistanceMatrix
  describe PolylineEncoder do
    tests = {
      [[38.5, -120.2]] => '_p~iF~ps|U',
      #[[38.5, -120.2], [40,7, -120.95], [43.252, -126.453]] => '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
    }

    tests.each_pair do |lat_lng_values, expected|
      xit "encodes #{lat_lng_values} to #{expected}" do
        expect(described_class.encode lat_lng_values).to eq expected
      end
    end
  end
end
