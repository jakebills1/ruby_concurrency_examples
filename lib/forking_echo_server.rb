require 'socket'

class ForkingEchoServer
  def self.run(port:)
    Process.setproctitle('echo_server')
    server = TCPServer.new port
    # trap interrupt signal
    trap(:INT) { exit }

    loop do
      # blocking call to accept to get new connection
      @client = server.accept

      # fork process to do blocking IO ops with client
      pid = fork do
        Process.setproctitle('echo_server [child]')

        server.close
        while echo = @client.gets
          # blocking write to client
          @client.puts echo
        end
        @client.close
      end
      # make sure to detach after forking process to handle client
      Process.detach(pid)
    end
    server.close
  end
end
