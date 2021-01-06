require 'socket'
require_relative '../methods'
require_relative '../Mutex/Lamport'

MY_ID = 'A2'.freeze

lamport = Lamport.new(3, 1)

# Open our server
lwa2 = TCPServer.open(8082)

# Connect to HW Server
server = TCPSocket.open('localhost', 8080)

sleep 5

# Connect to other LWs Server
lwa1 = TCPSocket.open('localhost', 8081)
lwa3 = TCPSocket.open('localhost', 8083)

# Accept other LWs Connection
server_lwa1 = lwa2.accept
server_lwa3 = lwa2.accept

Thread.new { lamport.handle_msg(server_lwa1, 0) }
Thread.new { lamport.handle_msg(server_lwa3, 2) }

loop do
  wait_heavy_weight(server)
  lamport.request_cs(lwa1, lwa3)

  10.times do
    server.puts "Sóc el procés lightweight #{MY_ID}"
    sleep 1
  end

  lamport.release_cs(lwa1, lwa3)
  notify_heavy_weight(server)
end

