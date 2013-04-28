require "spec_helper"

describe GoogleDistanceMatrix::Logger do
  context "without a logger backend" do
    subject { described_class.new }

    described_class::LEVELS.each do |level|
      it "logging #{level} does not fail" do
        subject.public_send level, "log msg"
      end
    end
  end

  context "with a logger backend" do
    let(:backend) { mock }

    subject { described_class.new backend }

    described_class::LEVELS.each do |level|
      describe level do
        it "sends log message to the backend" do
          backend.should_receive(level).with("[google_distance_matrix] log msg")
          subject.public_send level, "log msg"
        end

        it "supports sending in a tag" do
          backend.should_receive(level).with("[google_distance_matrix] [client] log msg")
          subject.public_send level, "log msg", tag: :client
        end

        it "supports sending in multiple tags" do
          backend.should_receive(level).with("[google_distance_matrix] [client] [request] log msg")
          subject.public_send level, "log msg", tag: ['client', 'request']
        end
      end
    end
  end
end
