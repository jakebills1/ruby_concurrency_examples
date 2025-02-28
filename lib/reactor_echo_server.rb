# frozen_string_literal: true

require 'socket'
require 'logger'
require 'nio'

class ReactorEchoServer
  DEBUG = ENV['DEBUG']
  MESSAGE_MAXLEN = 10000

  def initialize(logger: Logger.new($stdout), port:)
    trap(:INT) { exit }
    @logger = logger
    @server = TCPServer.new port
    @selector = NIO::Selector.new
  end

  def run
    monitor = selector.register(server, :r)
    monitor.value = proc { accept_new_client }
    loop do
      selector.select { |monitor| monitor.value.call }
    end
  ensure
    server.close
    selector.close
  end

  private
  attr_reader :logger, :server, :selector

  def log(msg)
    return unless DEBUG

    logger.add Logger::DEBUG, msg
  end

  def accept_new_client
    client = server.accept
    log 'accepted new client'
    monitor = selector.register(client, :r)
    monitor.value = proc { read_from_client(monitor) }
  end

  def read_from_client(monitor)
    begin
      message = monitor.io.read_nonblock(MESSAGE_MAXLEN)
      monitor.interests = :w
      monitor.value = proc { write_to_client(monitor, message) }
    rescue IO::WaitReadable
      # monitor.value = proc { read_from_client(monitor) }
    rescue EOFError
      log 'client disconnected'
      selector.deregister(monitor)
      monitor.close
    end
  end

  def write_to_client(monitor, message)
    monitor.io.write_nonblock(message)
    monitor.interests = :r
    monitor.value = proc { read_from_client(monitor) }
  rescue IO::WaitWritable
    # monitor.value = proc { write_to_client(monitor, message) }
  end
end
