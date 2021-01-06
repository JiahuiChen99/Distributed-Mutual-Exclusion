require 'socket'
require_relative '../methods'
require_relative '../Mutex/Lamport'

MY_ID = 'A1'.freeze

lamport = Lamport.new(3, 0)

# Open our server
lwa1 = TCPServer.open(8081)

# Connect to HW Server
server = TCPSocket.open('localhost', 8080)

sleep 5

# Connect to other LWs Server
lwa2 = TCPSocket.open('localhost', 8082)
lwa3 = TCPSocket.open('localhost', 8083)

# Accept other LWs Connection
server_lwa2 = lwa1.accept
server_lwa3 = lwa1.accept

Thread.new { lamport.handle_msg(server_lwa2, 1) }
Thread.new { lamport.handle_msg(server_lwa3, 2) }

loop do
  wait_heavy_weight(server)
  lamport.request_cs(lwa2, lwa3)

  10.times do
    server.puts "Sóc el procés lightweight #{MY_ID}"
    sleep 1
  end

  lamport.release_cs(lwa2, lwa3)
  notify_heavy_weight(server)
end
