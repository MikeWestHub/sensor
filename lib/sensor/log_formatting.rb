module Sensor
  module LogFormatting
    def process_start_for(pid)
      date = %x{ps -eo pid,lstart | grep #{pid}}.split(" ").drop(2)
      time = date.delete_at(2).split(":")
      Time.new(date[2],date[0],date[1],time[0],time[1],time[2]).utc
    end

    def username_for(pid)
      `ps aux | grep #{pid} | awk '{print $1}'`.split("\n").first
    end
  end
end
