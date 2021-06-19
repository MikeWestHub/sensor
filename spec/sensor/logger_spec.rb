require "spec_helper"

RSpec.describe Sensor::Logger do
  let(:log_line) { { activity: "test"} }
  let(:test_file) { File.expand_path("#{File.dirname(__FILE__)}/../../spec/sensor-test.log") }
  let(:json) { JSON.parse(File.open(test_file, &:readline)) }

  before do
    stub_const("Sensor::Logger::LOG_FILE", test_file)
  end

  after do
    File.delete(test_file)
  end

  describe ".activity" do
    it "adds a timestamp to the log line" do
      described_class.activity(log_line)
      expect(json.keys).to include("timestamp")
    end

    it "creats a new file for writing if it doesn't exist" do
      allow(File).to receive(:new).and_call_original
      described_class.activity(log_line)
      expect(File).to have_received(:new).with(test_file, "w")
    end

    context "when a file does exist" do
      before do
        File.new(test_file, "w")
      end

      it "opens the existing file" do
        allow(File).to receive(:open).and_call_original
        described_class.activity(log_line)
        expect(File).to have_received(:open).with(test_file, "a")
      end
    end
  end

  describe ".error" do
    let(:error) { StandardError.new(message: "test error") }

    it "logs the error" do
      described_class.error(error)
      expect(json["type"]).to eql("error")
      expect(json["message"]).to eql(error.message)
      expect(json["class"]).to eql(error.class.to_s)
    end

    it "adds a timestamp to the log line" do
      described_class.error(error)
      expect(json.keys).to include("timestamp")
    end
  end
end
