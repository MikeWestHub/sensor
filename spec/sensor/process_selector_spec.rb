require "spec_helper"

RSpec.describe Sensor::ProcessSelector do
  let(:selector) { described_class.new(input: input) }
  let(:filename) { "foo.txt" }

  describe ".run" do
    context "when the action is to write" do
      let(:input) { { filename: filename, write: true, content: "puts 'Hello Friends'" } }

      it "logs and selects the write process" do
        expect(selector).to receive(:fork).and_yield do |block_context|
          expect(block_context).to receive(:log_activity)
          expect(block_context).to receive(:send).with("write_to_file")
        end

        selector.run
      end
    end

    context "when the action is to update" do
      let(:input) { { filename: filename, update: true, content: "puts 'Hola Amigos'" } }

      it "logs and selects the update process" do
        expect(selector).to receive(:fork).and_yield do |block_context|
          expect(block_context).to receive(:log_activity)
          expect(block_context).to receive(:send).with("update_file")
        end

        selector.run
      end
    end

    context "when the action is to delete" do
      let(:input) { { filename: filename, delete: true } }

      it "logs and selects the delete process" do
        expect(selector).to receive(:fork).and_yield do |block_context|
          expect(block_context).to receive(:log_activity)
          expect(block_context).to receive(:send).with("delete_file")
        end

        selector.run
      end
    end

    context "when no input are provided" do
      let(:input) { {} }

      it "logs and selects the execute process" do
        expect(selector).to receive(:fork).and_yield do |block_context|
          expect(block_context).to receive(:log_activity)
          expect(block_context).to receive(:send).with("execute_file")
        end

        selector.run
      end
    end

    context "when the forward flag is set" do
      let(:input) { { filename: filename, update: true, content: "puts 'Hola Amigos'", forward: true } }
      let(:socket) { double('TCPSocket', write: true, close: true) }

      it "calls the HttpForwarder" do
        allow(Sensor::HttpForwarder).to receive(:new).and_call_original
        selector.run
        expect(Sensor::HttpForwarder).to have_received(:new).with(file_info: input)
      end
    end

    context "when the forward flag is not set" do
      let(:input) { { filename: filename, update: true, content: "puts 'Hola Amigos'" } }

      it "doesn't call the HttpForwarder" do
        expect(Sensor::HttpForwarder).to_not receive(:new)
        selector.run
      end
    end
  end
end
