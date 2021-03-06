# Forwards Sensor activity on to a configurable
# host and port
require "socket"
require "json"
require_relative './log_formatting'

module Sensor
  class HttpForwarder
    include LogFormatting

    ADDRESS = ENV.fetch('HOST', 'localhost')
    PORT = ENV.fetch('PORT', 2000)

    attr_reader :file_info

    def initialize(file_info:)
      @file_info = file_info
    end

    def send_data
      info = file_info_json
      s = TCPSocket.new ADDRESS, PORT

      s.write "POST / HTTP/1.1\r\n"
      s.write "Host: #{ADDRESS}\r\n"
      s.write "Content-Type: application/json\r\n"
      s.write "Content-Length: #{info.bytesize}\r\n\r\n"
      s.write "#{info}\r\n"

      log_activity(info, s)

      s.close
    rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL
      puts "Connection refused. Make sure a server is running at your assign ADDRESS and PORT."
    end

    def file_info_json
      {
        forwarded_at: Time.now.utc,
        sensor_info: {
          filename: file_info[:filename],
          file_action: file_info.delete(:action),
          file_content: file_info[:content],
          executable_output: file_info.delete(:output),
          command_line: file_info
        }
      }.to_json
    end

    private

    def log_activity(info, socket)
      pid = Process.pid

      hsh = {
        action: :network_request,
        process_started_at: process_start_for(pid),
        username: username_for(pid),
        user_id: Process.uid,
        process_id: Process.pid,
        process_name: Process.argv0,
        destination: {
          address: ADDRESS,
          port: PORT
        },
        source: {
          address: Socket.gethostname,
          port: socket.addr[1]
        },
        protocol: "HTTP",
        payload_size: "#{info.bytesize} bytes",
        payload: JSON.parse(info)
      }

      Sensor::Logger.activity(hsh)
    end
  end
end
