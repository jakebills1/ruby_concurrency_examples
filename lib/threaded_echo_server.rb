require 'socket'

class ThreadedEchoServer
  def self.run(port:)
    server = TCPServer.new port
    # trap interrupt signal
    trap(:INT) { exit }

    loop do
      # blocking call to accept to get new connection
      client = server.accept
      puts "accepted client"

      # spawn thread per connection 
      Thread.new(client) do
        while echo = client.gets
          # blocking write to client
          client.puts echo 
        end
        client.close
      end
    end
    server.close
  end
end
