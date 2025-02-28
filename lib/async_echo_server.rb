# frozen_string_literal: true
require 'async'
require 'io/endpoint/host_endpoint'

class AsyncEchoServer
  def initialize(port:)
    @server = IO::Endpoint.tcp("localhost", port)
    trap('INT') { exit(1) }
    puts Process.pid
    puts Thread.current.inspect
  end

  def run
    Async do
      server.accept do |client|
        puts "in accept block."
        puts "pid = #{Process.pid}"
        puts "thread = #{Thread.current.inspect}"
        puts "fiber = #{Fiber.current}"
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
