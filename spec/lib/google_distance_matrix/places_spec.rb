require "spec_helper"

describe GoogleDistanceMatrix::Places do
  let(:values) { [1, 3, 2] }

  subject { described_class.new values }

  it { should include *values }
  it { should_not include 5 }

  it "keeps it's values uniq" do
    subject << 5

    expect {
      subject << 5
    }.to_not change(subject, :length)
  end

  it "has << which is chanable" do
    subject << 6 << 8
    expect(subject).to include 6, 8
  end
end
