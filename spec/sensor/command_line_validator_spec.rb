require "spec_helper"

RSpec.describe Sensor::CommandLineValidator do
  let(:validator) { described_class.new(input: input) }

  describe ".validate" do
    context 'with too many flags' do
      let(:input) { { file: "foo.csv", execute: true, delete: true } }

      it 'raises a validation error' do
        expect { validator.validate }.to raise_error(Sensor::ValidationError, /cannot be passed with other flags/)
      end
    end

    context 'when writing or updating' do
      context 'without the content flag' do
        let(:input) { { file: "foo.csv", write: true } }

        it 'raises a validation error' do
          expect { validator.validate }.to raise_error(Sensor::ValidationError, /must be passed with --content/)
        end
      end

      context 'with too many flags' do
        let(:input) { { file: "foo.csv", write: true, execute: true, content: "awesome,content" } }

        it 'raises a validation error' do
          expect { validator.validate }.to raise_error(Sensor::ValidationError, /--content is the only supported flag/)
        end
      end

      context 'when passing the context flag to delete or execute' do
        let(:input) { { file: "foo.csv", execute: true, content: "awesome,content" } }

        it 'raises a validation error' do
          expect { validator.validate }.to raise_error(Sensor::ValidationError, /cannot be passed with other flags/)
        end
      end
    end
  end
end
