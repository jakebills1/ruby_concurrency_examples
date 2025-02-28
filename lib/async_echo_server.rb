# frozen_string_literal: true
require 'async'
require 'io/endpoint/host_endpoint'

class AsyncEchoServer
  include DebugLogger
  def initialize(port:)
    @server = IO::Endpoint.tcp("localhost", port)
    trap('INT') { exit(1) }
    log Process.pid
    log Thread.current.inspect
  end

  def run
    Async do
      server.accept do |client|
        log "in accept block."
        log "pid = #{Process.pid}"
        log "thread = #{Thread.current.inspect}"
        log "fiber = #{Fiber.current}"
        while message = read_from_client(client)
          write_to_client(client, message)
        end
        client.close
      end
    end
  end

  def read_from_client(client)
    client.gets
  end

  def write_to_client(client, message)
    client.puts message
  end

  private
  attr_reader :server
end
