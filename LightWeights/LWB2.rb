require 'socket'
require_relative '../methods'
require_relative '../Mutex/RicartAgrawala'

MY_ID = 'B2'.freeze

ricart_agrawala = RicartAgrawala.new(3, 1)

# Open our server
lwb2 = TCPServer.open(8092)

# Connect to HW Server
server = TCPSocket.open('localhost', 8090)

sleep 5

# Connect to other LWs Server
lwb1 = TCPSocket.open('localhost', 8091)
lwb3 = TCPSocket.open('localhost', 8093)

# Accept other LWs Connection
server_lwb2 = lwb2.accept
server_lwb3 = lwb2.accept

Thread.new { ricart_agrawala.handle_msg(server_lwb2, 0, lwb1, lwb2, lwb3) }
Thread.new { ricart_agrawala.handle_msg(server_lwb3, 2, lwb1, lwb2, lwb3) }

loop do
  wait_heavy_weight(server)
  ricart_agrawala.request_cs(lwb1, lwb3)

  10.times do
    server.puts "Sóc el procés lightweight #{MY_ID}"
    sleep 1
  end

  ricart_agrawala.release_cs(lwb1, lwb2, lwb3)
  notify_heavy_weight(server)
end
