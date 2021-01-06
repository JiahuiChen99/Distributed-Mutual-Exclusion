require 'socket'

# Notify HW's LW that they can use the resource
# They'll have to mutually exclude themselves using
# a Distributed Mutual Exclusion Algorithm
def wait_heavy_weight(server)
  while (msg = server.gets)
    puts msg
    break if msg.chop.eql? 'yes token'
  end
end

def notify_heavy_weight(server)
  server.puts 'done'
end

# Constantly listening whether we have the token or not
def listen_heavyweight(heavyweight_b)
  msg = heavyweight_b.gets
  return true if msg.chop.eql? 'yes token'

  false
end

def send_action_to_lightweight(client)
  client.puts 'yes token'
end

def listen_lightweight(clients, answers_from_light_weight)

  # Listen to all 3 clients for a "done" message
  rs = IO.select(clients)
  if (readable = rs[0])
    readable.each do |client|
      msg = client.gets
      if msg.chop.eql? 'done'
        return answers_from_light_weight += 1
      else
        puts msg
      end
    end
  end

  return answers_from_light_weight
end

def send_token_to_heavyweight(heavyweight)
  heavyweight.puts 'yes token'
end
