require_relative './lib/serial_echo_server'
PORT = 2000 # customize which port the server binds to

# change me to test a particular echo server implementation
# eg EventedEchoServer.new(port: PORT).run
SerialEchoServer.run(port: PORT)