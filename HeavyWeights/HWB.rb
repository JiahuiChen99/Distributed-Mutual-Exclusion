require 'socket'
require_relative '../methods'

NUM_LIGHTWEIGHTS = 3
token = false
lightweights_sockets = Array.new(NUM_LIGHTWEIGHTS)

socket = TCPServer.open(8090)

# Connection to the other heavyweight A after 2 seconds
sleep 2
heavyweight_a = TCPSocket.open('localhost', 8080)

# Accept HWB Connection
hw_a = socket.accept

puts "HWB Running - Waiting for connection..."

3.times do |index|
  client = socket.accept
  puts "Client ##{index} connected"
  lightweights_sockets[index] = client
end

loop do
  answers_from_light_weight = 0
  token = listen_heavyweight(hw_a) until token

  3.times do |index|
    send_action_to_lightweight(lightweights_sockets[index])
  end

  # answers_from_light_weight = listen_lightweight(lightweights_sockets, answers_from_light_weight) while answers_from_light_weight < NUM_LIGHTWEIGHTS
  while answers_from_light_weight < NUM_LIGHTWEIGHTS
    answers_from_light_weight = listen_lightweight(lightweights_sockets, answers_from_light_weight)
  end

  token = false
  puts "Token passed to HW A"
  send_token_to_heavyweight(heavyweight_a)
end
