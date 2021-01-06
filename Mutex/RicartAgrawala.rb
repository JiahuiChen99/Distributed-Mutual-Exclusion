require 'socket'
require_relative '../Clocks/lamport_clock'

class RicartAgrawala
  @@myts
  @@lamport_clock
  @@pending_queue
  @@num_okay
  @@n_times
  @@my_Id

  def initialize(n_times, my_id)
    @@myts = Float::INFINITY
    @@lamport_clock = LamportClock.new
    @@pending_queue = Array.new(3)
    @@n_times = n_times
    @@my_id = my_id
  end

  def request_cs(server1, server2)
    @@lamport_clock.tick
    @@myts = @@lamport_clock.get_value
    server1.puts "request-#{@@myts}"
    server2.puts "request-#{@@myts}"
    @@num_okay = 0

    while @@num_okay < @@n_times - 1
      # puts @@num_okay.to_s + " " + @@n_times.to_s
    end
  end

  def release_cs(lwb1, lwb2, lwb3)
    @@myts = Float::INFINITY
    until @@pending_queue.empty?
      pid = @@pending_queue.shift

      case pid
        when 0
          lwb1.puts "okay-#{@@lamport_clock.get_value}"
        when 1
          lwb2.puts "okay-#{@@lamport_clock.get_value}"
        when 2
          lwb3.puts "okay-#{@@lamport_clock.get_value}"
        else
      end
    end
  end

  def handle_msg(source, source_id, server1, server2, server3)

    while(msg = source.gets)
      case source_id
      when 0
        sv = server1
        puts 'LWB1 Requesting CS'
      when 1
        sv = server2
        puts 'LWB2 Requesting CS'
      when 2
        sv = server3
        puts 'LWB3 Requesting CS'
      end

      puts msg

      split = msg.split('-')
      time_stamp = split[1].chop.to_i
      @@lamport_clock.receive_action(source_id, time_stamp)

      if msg.chop.include? 'request'
        if (@@myts == Float::INFINITY) || (time_stamp < @@myts) || ((@@myts == time_stamp) && (source_id < @@my_id))
          sv.puts "okay-#{@@lamport_clock.get_value}"
        else
          @@pending_queue.push(source_id)
        end
      elsif msg.chop.include? 'okay'
        puts
        @@num_okay += 1
        # if @@num_okay == @@n_times - 1
        # end
      end
    end
  end
end