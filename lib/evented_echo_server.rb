require 'socket'

class EventedEchoServer
  include DebugLogger
  MESSAGE_MAXLEN = 10000
  
  def initialize(port:)
    @to_read = []
    @to_write = []
    @messages = {}
    trap(:INT) { exit }
    @server = TCPServer.new port
  end

  def run
    to_read << server
    loop do
      log 'waiting for ready sockets'
      ready_to_read, ready_to_write = IO.select(to_read, to_write)


      ready_to_read.each do |socket|
        if socket == server
          accept_new_client(socket)
        else
          read_from_client(socket)
        end
      end
      # handle writes ?
      log 'finished read loop'
      ready_to_write.each do |socket|
        write_to_client(socket)
      end
      log 'finished write loop'
    end
  ensure
    server.close
  end

  private 
  attr_reader :to_read, :to_write, :messages, :server

  def accept_new_client(socket)
    begin
      client = server.accept_nonblock
    rescue IO::WaitReadable
      IO.select([socket])
      retry
    end
    messages[client] = []
    to_read << client
  end

  def read_from_client(socket)
    begin
      message = socket.read_nonblock(MESSAGE_MAXLEN)
      messages[socket].push(message)
      if !to_write.include?(socket)
        to_write << socket
      end
    rescue IO::WaitReadable
      if !to_read.include?(socket)
        to_read << socket
      end
    rescue EOFError
      messages.delete(socket)
      to_read.delete(socket)
      to_write.delete(socket)
      socket.close
    end
  end

  def write_to_client(socket)
    message_queue = messages[socket]
    until message_queue.empty?
      message = message_queue.shift
      begin
        socket.write_nonblock(message)
      rescue IO::WaitWriteable
        # push message back to message queue
        message_queue.unshift(message)
        if !to_write.include?(socket)
          to_write << socket
        end
      end
    end
    to_write.delete(socket)
  end
end
