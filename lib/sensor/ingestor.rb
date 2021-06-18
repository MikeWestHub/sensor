# Entry point for the Sensor framework
# Currently CLI is the only supported source for ingestion

module Sensor
  class Ingestor
    attr_reader :input

    def initialize(input:)
      @input = input
    end

    def self.read_from_cli(input)
      new(input: input).process_cli_input
    end

    def process_cli_input
      validate_input
    rescue ValidationError => e
      log_error(e)
      puts "Validation Error: #{e.message}"
    end

    private

    def validate_input
      Sensor::CommandLineValidator.new(input: input).validate
    end

    def log_error(error)
      Sensor::Logger.error(error)
    end
  end
end
