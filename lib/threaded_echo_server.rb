require 'socket'
require_relative './debug_logger'

class ThreadedEchoServer
  extend DebugLogger

  def self.run(port:)
    server = TCPServer.new port
    # trap interrupt signal
    trap(:INT) { exit }

    loop do
      # blocking call to accept to get new connection
      client = server.accept
      log "accepted client"

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
