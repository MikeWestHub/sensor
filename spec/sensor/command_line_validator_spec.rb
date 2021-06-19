require "spec_helper"

RSpec.describe Sensor::CommandLineValidator do
  let(:validator) { described_class.new(input: input) }
  let(:good_file) { File.new("test_file", "w") }

  after do
    File.delete(good_file)
  end

  describe ".validate" do
    context "with too many flags" do
      let(:input) { { filename: good_file, execute: true, delete: true } }

      it "raises a validation error" do
        expect { validator.validate }.to raise_error(Sensor::ValidationError, /cannot be passed with other flags/)
      end
    end

    context "when trying to act on a file that doesn't exist (not including write actions)" do
      let(:input) { { filename: "foo.csv", execute: "true" } }

      it "raises a validation error" do
        expect { validator.validate }.to raise_error(Sensor::ValidationError, /Please provide the full path to the file/)
      end
    end

    context "when passing the context flag to delete or execute" do
      let(:input) { { filename: good_file, execute: true, content: "awesome,content" } }

      it "raises a validation error" do
        expect { validator.validate }.to raise_error(Sensor::ValidationError, /cannot be passed with other flags/)
      end
    end

    context "when writing or updating" do
      context "without the content flag" do
        let(:input) { { filename: good_file, write: true } }

        it "raises a validation error" do
          expect { validator.validate }.to raise_error(Sensor::ValidationError, /must be passed with --content/)
        end
      end

      context "when the content flag is passed alone" do
        let(:input) { { filename: good_file, content: "foo" } }

        it "raises a validation error" do
          expect { validator.validate }.to raise_error(Sensor::ValidationError, /--write or --update flags must be provided/)
        end
      end
    end
  end
end
