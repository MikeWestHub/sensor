require 'json'

module Sensor
  class Logger
    LOG_FILE = File.expand_path("#{File.dirname(__FILE__)}/../../logs/sensor.log")

    def self.activity(subprocess = {})
      hsh = {
        username: `who -m | awk '{print $1}'`,
        user_id: File::Stat.new(Process.argv0).uid,
        process_name: Process.argv0,
        process_id: Process.pid,
        process_started_at: File::Stat.new(Process.argv0).birthtime,
        subprocess: subprocess
      }

      write_to_log(hsh)
    end

    def self.error(error)
      hsh = {
        type: :error,
        class: error.class,
        message: error.message
      }

      write_to_log(hsh)
    end

    private

    def self.write_to_log(hsh)
      hsh.merge!(timestamp: Time.now.utc)

      if File.exist?(LOG_FILE)
        f = File.open(LOG_FILE, "a")
      else
        f = File.new(LOG_FILE, "w")
      end

      f << "#{hsh.to_json}\n"
      f.close
    end
  end
end
