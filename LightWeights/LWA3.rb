require 'socket'
require_relative '../methods'
require_relative '../Mutex/Lamport'

MY_ID = 'A3'.freeze

lamport = Lamport.new(3, 2)

# Open our server
lwa3 = TCPServer.open(8083)

# Connect to HW Server
server = TCPSocket.open('localhost', 8080)

sleep 5

# Connect to other LWs Server
lwa1 = TCPSocket.open('localhost', 8081)
lwa2 = TCPSocket.open('localhost', 8082)

# Accept other LWs Connection
server_lwa1 = lwa3.accept
server_lwa2 = lwa3.accept

Thread.new { lamport.handle_msg(server_lwa1, 0) }
Thread.new { lamport.handle_msg(server_lwa2, 1) }

loop do
  wait_heavy_weight(server)
  lamport.request_cs(lwa1, lwa2)

  10.times do
    server.puts "Sóc el procés lightweight #{MY_ID}"
    sleep 1
  end

  lamport.release_cs(lwa1, lwa2)
  notify_heavy_weight(server)
end


