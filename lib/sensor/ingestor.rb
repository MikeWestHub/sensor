# Entry point for the Sensor framework
# Currently CLI is the only supported source for ingestion
require_relative './log_formatting'

module Sensor
  class Ingestor
    include LogFormatting

    attr_reader :input

    def initialize(input:)
      @input = input
    end

    def self.read_from_cli(input)
      new(input: input).process_cli_input
    end

    def process_cli_input
      log_activity
      validate_input
      process_input
    rescue ValidationError, NetworkingError => e
      log_error(e)
      puts "Your request returned #{e.class}: #{e.message}"
    end

    private

    def validate_input
      Sensor::CommandLineValidator.new(input: input).validate
    end

    def process_input
      Sensor::ProcessSelector.new(input: input).run
    end

    def log_activity
      pid = Process.pid

      hsh = {
        action: :command_line_request,
        process_started_at: process_start_for(pid),
        username: username_for(pid),
        user_id: Process.uid,
        process_name: Process.argv0,
        process_id: pid,
        commandline: input
      }

      Sensor::Logger.activity(hsh)
    end

    def log_error(error)
      Sensor::Logger.error(error)
    end
  end
end
