require 'spec_helper'

module GoogleDistanceMatrix
  describe PolylineEncoder do
    tests = {
      [[-179.9832104, -179.9832104]] => '`~oia@`~oia@',
      [[38.5, -120.2], [40.7, -120.95], [43.252, -126.453]] => '_p~iF~ps|U_ulLnnqC_mqNvxq`@',
      [[41.3522171071184, -86.0456299662023],[41.3522171071183, -86.0454368471533]] => 'krk{FdxdlO?e@'
    }

    tests.each_pair do |lat_lng_values, expected|
      it "encodes #{lat_lng_values} to #{expected}" do
        expect(described_class.encode lat_lng_values).to eq expected
      end
    end
  end
end
