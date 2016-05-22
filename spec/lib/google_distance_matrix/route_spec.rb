require "spec_helper"

describe GoogleDistanceMatrix::Route do
  let(:attributes) do
    {
      "distance" => {"text" => "2.0 km", "value" => 2032},
      "duration" => {"text" =>"6 mins",  "value" => 367},
      "duration_in_traffic" => {"text" =>"5 mins",  "value" => 301},
      "status" =>"OK"
    }
  end

  subject { described_class.new attributes }

  it { expect(subject.status).to eq "ok" }
  it { expect(subject.distance_in_meters).to eq 2032 }
  it { expect(subject.distance_text).to eq "2.0 km" }
  it { expect(subject.duration_in_seconds).to eq 367 }
  it { expect(subject.duration_text).to eq "6 mins" }
  it { expect(subject.duration_in_traffic_in_seconds).to eq 301 }
  it { expect(subject.duration_in_traffic_text).to eq "5 mins" }

  it { is_expected.to be_ok }
end
