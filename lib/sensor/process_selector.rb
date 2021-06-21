# Takes a filename and options and starts the appropriate
# process based on those inputs
require_relative './log_formatting'

module Sensor
  class ProcessSelector
    include LogFormatting

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
    end

    def write_to_file
      f = File.new(filename, "w")
      f << "#{input[:content]}\n"
      f.close
    rescue Errno::EACCES
      permission_denied
    end

    def update_file
      f = File.open(filename, "a")
      f << "#{input[:content]}\n"
      f.close
    rescue Errno::EACCES
      permission_denied
    end

    def delete_file
      File.delete(filename)
    rescue Errno::EACCES
      permission_denied
    end

    def execute_file
      output = ""

      IO.popen(filename).each_line do |line|
        output << "#{line}\n"
      end

      forward_activity(output: output)
    rescue Errno::EACCES
      permission_denied
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

    def permission_denied
      puts "Permission denied for #{filename}. Try setting the correct file permissions before atempting execution"
    end

    def log_activity
      pid = Process.pid

      hsh = {
        action: "#{find_action_from_flag}_file".to_sym,
        process_started_at: process_start_for(pid),
        username: username_for(pid),
        user_id: Process.uid,
        process_name: Process.argv0,
        process_id: pid,
        path_to_file: filename,
        commandline: input
      }

      Sensor::Logger.activity(hsh)
    end
  end
end
