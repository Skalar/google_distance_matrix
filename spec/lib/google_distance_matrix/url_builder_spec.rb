require "spec_helper"

describe GoogleDistanceMatrix::UrlBuilder do
  let(:origin) { GoogleDistanceMatrix::Place.new address: "Karl Johans Gate, Oslo" }
  let(:destination) { GoogleDistanceMatrix::Place.new lat: 1.2, lng: 2 }

  let(:origins) { [origin] }
  let(:destinations) { [destination] }

  let(:matrix) do
    GoogleDistanceMatrix::Matrix.new(
      origins: origins,
      destinations: destinations
    )
  end

  subject { described_class.new matrix }

  its(:matrix) { should eq matrix }
end
