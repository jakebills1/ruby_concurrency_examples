require 'socket'

def get_line
  puts "Enter a message to send to the server:"
  gets
end

port = ENV['PORT'] || 2000
conn = TCPSocket.new 'localhost', port

trap('INT') do
  conn.close
  exit
end

while line = get_line
  conn.puts line
  puts "The server says back: #{conn.gets}"
end

conn.close