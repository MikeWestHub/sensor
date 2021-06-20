require "spec_helper"

RSpec.describe Sensor::HttpForwarder do
  let(:file_info) { { filename: "/bin/ls", action: "execute", output: "sensor" } }
  let(:forwarder) { described_class.new(file_info: file_info) }

  describe '.send_data' do
    before do
      allow(TCPSocket).to receive(:new).and_return(double('TCPSocket', write: true, close: true))
      allow(forwarder).to receive(:log_activity).and_return(true)
    end

    it 'creates a new socket connection' do
      expect(TCPSocket).to receive(:new).with(Sensor::HttpForwarder::ADDRESS, Sensor::HttpForwarder::PORT)
      forwarder.send_data
    end

    it 'logs the activity' do
      expect(forwarder).to receive(:log_activity)
      forwarder.send_data
    end
  end

  describe '.file_info_json' do
    it 'returns JSON based on the input' do
      json = forwarder.file_info_json
      body = JSON.parse(json)["sensor_info"]
      expect(body["filename"]).to eql("/bin/ls")
      expect(body["file_action"]).to eql("execute")
      expect(body["file_content"]).to be_nil
      expect(body["executable_output"]).to eql("sensor")
    end
  end
end
