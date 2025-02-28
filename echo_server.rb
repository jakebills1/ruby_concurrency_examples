Dir["./lib/*.rb"].each { |file| require file }
port = ENV['PORT'] || 2000 # customize which port the server binds to

# change me to test a particular echo server implementation
# eg EventedEchoServer.new(port:).run
SerialEchoServer.run(port:)