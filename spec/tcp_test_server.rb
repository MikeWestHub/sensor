require 'socket'

server = TCPServer.open(2000)

loop {
  client = server.accept

  while line = client.gets
    puts line.chop
  end

  puts "Got your data"

  client.close_write
}
