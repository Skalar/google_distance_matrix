require "spec_helper"

describe GoogleDistanceMatrix::Route do
  let(:attributes) do
    {
      "distance" => {"text" => "2.0 km", "value" => 2032},
      "duration" => {"text" =>"6 mins",  "value" => 367},
      "status" =>"OK"
    }
  end

  subject { described_class.new attributes }

  its(:status) { should eq "ok" }
  its(:distance_value) { should eq 2032 }
  its(:distance_text) { should eq "2.0 km" }
  its(:duration_value) { should eq 367 }
  its(:duration_text) { should eq "6 mins" }

  it { should be_ok }
end
