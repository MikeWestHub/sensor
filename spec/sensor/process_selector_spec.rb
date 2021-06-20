require "spec_helper"

RSpec.describe Sensor::ProcessSelector do
  let(:selector) { described_class.new(filename: "foo.rb", options:  options) }

  describe ".run" do
    context "when the options are to write" do
      let(:options) { { write: true, content: "puts 'Hello Friends'" } }

      it "selects the write process" do
        allow(selector).to receive(:write_to_file)
        selector.run
        expect(selector).to have_received(:write_to_file)
      end

      it 'logs the process' do
        expect(Sensor::Logger).to receive(:activity)
        selector.run
      end
    end

    context "when the options are to update" do
      let(:options) { { update: true, content: "puts 'Hola Amigos'" } }

      it "selects the update process" do
        allow(selector).to receive(:update_file)
        selector.run
        expect(selector).to have_received(:update_file)
      end 

      it 'logs the process' do
        expect(Sensor::Logger).to receive(:activity)
        selector.run
      end
    end

    context "when the options are to delete" do
      let(:options) { { delete: true } }

      it "selects the delete process" do
        allow(selector).to receive(:delete_file)
        selector.run
        expect(selector).to have_received(:delete_file)
      end 

      it 'logs the process' do
        expect(Sensor::Logger).to receive(:activity)
        selector.run
      end
    end

    context "when no options are provided" do
      let(:options) { {} }

      before do
        allow(IO).to receive(:popen).and_return({})
      end
      
      it "selects the execute process" do
        allow(selector).to receive(:execute_file)
        selector.run
        expect(selector).to have_received(:execute_file)
      end 

      it 'logs the process' do
        expect(Sensor::Logger).to receive(:activity)
        selector.run
      end
    end
  end
end
