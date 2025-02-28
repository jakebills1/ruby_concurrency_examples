require 'socket'

class SerialEchoServer
  def self.run(port:)
    server = TCPServer.new port
    # trap interrupt signal
    trap(:INT) { exit }

    loop do
      # blocking call to accept to get new connection
      @client = server.accept
      puts "accepted client"

      # blocking read from client
      while echo = @client.gets
        # blocking write to client
        @client.puts echo 
      end
      @client.close
      puts 'client left'
    end
    server.close
  end
end