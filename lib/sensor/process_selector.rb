# Takes a filename and options and starts the appropriate
# process based on those inputs

module Sensor
  class ProcessSelector
    attr_reader :filename, :options

    def initialize(filename:, options:)
      @filename = filename
      @options = options
    end

    def run
      action = find_action_from_flag
      start_process_for(action)
    end

    private

    def start_process_for(action)
      case action
      when "write"
        write_to_file
      when "update"
        update_file
      when "delete"
        delete_file
      when "execute"
        execute_file
      end
    rescue => e
      Sensor::Logger.error(e)
      puts "There was an issue with the #{action} action for #{filename}: #{e.message}"
    end

    def write_to_file
      f = File.new(filename, "w")
      f << "#{options[:content]}\n"

      log_activity

      f.close

      forward_activity
    end

    def update_file
      f = File.open(filename, "a")
      f << "#{options[:content]}\n"

      log_activity

      f.close

      forward_activity
    end

    def delete_file
      File.delete(filename)
      log_activity
      forward_activity
    end

    def execute_file
      output = ""

      IO.popen(filename).each_line do |line|
        output << "#{line}\n"
      end

      log_activity
      forward_activity(output: output)
    end

    def find_action_from_flag
      return "write" if options[:write] == true
      return "update" if options[:update] == true
      return "delete" if options[:delete] == true
      "execute" # will attempt to execute a file if no flags are passed
    end

    def forward_activity(output: nil)
      return unless options[:forward]

      info = commandline.merge!(action: find_action_from_flag)
      info.merge!(output: output) if output

      Sensor::HttpForwarder.new(file_info: info).send_data
    end

    def commandline
      { filename: filename }.merge!(options)
    end

    def log_activity
      hsh = {
        action: "#{find_action_from_flag}_file",
        username: `who -m | awk '{print $1}'`.strip,
        user_id: Process.uid,
        process_name: Process.argv0,
        process_id: Process.pid,
        process_started_at: File::Stat.new(Process.argv0).birthtime,
        path_to_file: filename,
        commandline: commandline
      }

      Sensor::Logger.activity(hsh)
    end
  end
end
