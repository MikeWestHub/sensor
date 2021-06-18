module Sensor
  class Ingest
    attr_reader :input

    def initialize(input:)
      @input = input
    end

    def self.from_cli(input)
      new(input: input).check_options
    end

    def check_options
      input
    end
  end
end
