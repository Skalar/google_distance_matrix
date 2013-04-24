require "spec_helper"

describe GoogleDistanceMatrix::UrlBuilder do
  let(:matrix) { mock }

  subject { described_class.new matrix }

  its(:matrix) { should eq matrix }
end
