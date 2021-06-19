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
      log_activity(f)
      f.close
    end

    def update_file
      f = File.open(filename, "a")
      f << "#{options[:content]}\n"
      log_activity(f)
      f.close
    end

    def delete_file
      File.delete(filename)
      log_activity
    end

    def execute_file
      output = IO.popen(filename)
      log_activiy(output)
    end

    def find_action_from_flag
      return "write" if options[:write] == true
      return "update" if options[:update] == true
      return "delete" if options[:delete] == true
      "execute" # will attempt to execute a file if no flags are passed
    end

    def log_activity(process = nil)
      Sensor::Logger.activity(info_for(process))
    end

    def info_for(subprocess)
      return unless subprocess
      stat = subprocess.stat

      {
        subprocess_user: stat.uid,
        subprocess_id: stat.extend(Process).send(:pid),
        subprocess_started_at: stat.birthtime,
        subprocess_command: { filename: filename }.merge!(options)
      }
    end
  end
end
