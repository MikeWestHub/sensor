require "spec_helper"

RSpec.describe Sensor::Ingestor do
  let(:options) { { file: "foo.csv" } }

  describe '.read_from_cli' do
    it 'creates a new Ingest object with the options' do
      allow(Sensor::Ingestor).to receive(:new).and_call_original
      described_class.read_from_cli(options)
      expect(Sensor::Ingestor).to have_received(:new).with(input: options)
    end
  end

  describe '.process_cli_input' do
    let(:ingestor) { described_class.new(input: options) }

    it 'calls the correct validator' do
      allow(Sensor::CommandLineValidator).to receive(:new).and_call_original
      ingestor.process_cli_input 
      expect(Sensor::CommandLineValidator).to have_received(:new).with(input: options)
    end
  end
end
