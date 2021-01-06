require 'socket'
require_relative '../methods'

NUM_LIGHTWEIGHTS = 3
token = true
lightweights_sockets = Array.new(NUM_LIGHTWEIGHTS)

socket = TCPServer.open(8080)

# Connection to the other heavyweight B after 2 seconds
sleep 2
heavyweight_b = TCPSocket.open('localhost', 8090)

# Accept HWB Connection
hw_b = socket.accept

puts "HWA Running - Waiting for connection..."

3.times do |index|
  client = socket.accept
  puts "Client ##{index} connected"
  lightweights_sockets[index] = client
end

loop do
  answers_from_light_weight = 0
  token = listen_heavyweight(hw_b) until token

  3.times do |index|
    send_action_to_lightweight(lightweights_sockets[index])
  end

  while answers_from_light_weight < NUM_LIGHTWEIGHTS
    answers_from_light_weight = listen_lightweight(lightweights_sockets, answers_from_light_weight)
  end

  token = false
  puts "Token passed to HW B"
  send_token_to_heavyweight(heavyweight_b)
end