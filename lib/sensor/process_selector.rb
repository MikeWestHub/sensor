# Takes a filename and options and starts the appropriate
# process based on those inputs

require 'pry'
module Sensor
  class ProcessSelector
    attr_reader :input, :filename

    PROCESS_MAP = {
      write: "write_to_file",
      update: "update_file",
      delete: "delete_file",
      execute: "execute_file"
    }.freeze

    def initialize(input:)
      @input = input
      @filename = input[:filename]
    end

    def run
      action = find_action_from_flag
      start_process_for(action)
    end

    private

    def start_process_for(action)
      fork {
        send(PROCESS_MAP[action])
        log_activity
      }

      forward_activity unless action == :execute
    rescue => e
      Sensor::Logger.error(e)
      puts "There was an issue with the #{action} action for #{filename}: #{e.message}"
    end

    def write_to_file
      f = File.new(filename, "w")
      f << "#{input[:content]}\n"
      f.close
    end

    def update_file
      f = File.open(filename, "a")
      f << "#{input[:content]}\n"
      f.close
    end

    def delete_file
      File.delete(filename)
    end

    def execute_file
      output = ""

      IO.popen(filename).each_line do |line|
        output << "#{line}\n"
      end

      forward_activity(output: output)
    end

    def find_action_from_flag
      return :write if input[:write] == true
      return :update if input[:update] == true
      return :delete if input[:delete] == true
      :execute # will attempt to execute a file if no flags are passed
    end

    def forward_activity(output: nil)
      return unless input[:forward]

      info = input.merge!(action: find_action_from_flag)
      info.merge!(output: output) if output

      Sensor::HttpForwarder.new(file_info: info).send_data
    end

    def log_activity
      hsh = {
        action: "#{find_action_from_flag}_file".to_sym,
        process_started_at: File::Stat.new(Process.argv0).birthtime,
        username: `who -m | awk '{print $1}'`.strip,
        user_id: Process.uid,
        process_name: Process.argv0,
        process_id: Process.pid,
        path_to_file: filename,
        commandline: input
      }

      Sensor::Logger.activity(hsh)
    end
  end
end
