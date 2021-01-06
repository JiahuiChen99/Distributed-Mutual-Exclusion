require 'socket'
require_relative '../Clocks/direct_clock'

class Lamport
  @@direct_clock
  @@request_queue
  @@my_id
  @@n_times
  # @@source_id

  def initialize(n_times, my_id)
    @@n_times = n_times
    @@my_id = my_id
    @@direct_clock = DirectClock.new(n_times, my_id)
    @@request_queue = Array.new(n_times)

    n_times.times do |index|
      @@request_queue[index] = Float::INFINITY
    end
  end

  # In case of equity, untied by id
  def is_greater(entry1, pid1, entry2, pid2)
    return false if entry2 == Float::INFINITY
    # puts "Value: " + entry1.to_s + " Client: " + pid1.to_s + " Value: "+ entry2.to_s + " Client: " + pid2.to_s
    # sleep 2
    ((entry1 > entry2) || ((entry1 == entry2) && (pid1 > pid2)))
  end

  def okayCS
    @@n_times.times do |index|
      return false if is_greater(@@request_queue[@@my_id], @@my_id, @@request_queue[index], index)
      return false if is_greater(@@request_queue[@@my_id], @@my_id, @@direct_clock.get_value(index), index)
    end

    true
  end

  # Send a "request" message to the other servers with our current server's timestamp on it
  def request_cs(server_1, server_2)
    puts "Requesting CS"
    @@direct_clock.tick
    @@request_queue[@@my_id] = @@direct_clock.get_value(@@my_id)
    server_1.puts "request-#{@@request_queue[@@my_id]}"
    server_2.puts "request-#{@@request_queue[@@my_id]}"
    # @@source_id = @@my_id
    # Infinite loop until it returns true - modified by handle_message
    until okayCS; end
  end

  def release_cs(server_1, server_2)
    @@request_queue[@@my_id] = Float::INFINITY
    server_1.puts "release-#{@@direct_clock.get_value(@@my_id)}"
    server_2.puts "release-#{@@direct_clock.get_value(@@my_id)}"
  end

  def handle_msg(source, source_id)

    while (msg = source.gets)
      case source_id
      when 0
        puts 'LWA1 Requesting CS'
      when 1
        puts 'LWA2 Requesting CS'
      when 2
        puts 'LWA3 Requesting CS'
      end

      puts msg

      split = msg.split('-')
      time_stamp = split[1].chop.to_i
      @@direct_clock.receive_action(source_id, time_stamp)

      if msg.chop.include? 'request'
        @@request_queue[source_id] = time_stamp
        source.puts "ack-#{@@direct_clock.get_value(@@my_id)}"
      else
        @@request_queue[source_id] = Float::INFINITY if msg.chop.include? 'release'
      end
      # @@source_id = source_id
    end
  end
end