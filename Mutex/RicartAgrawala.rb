require 'socket'
require_relative '../Clocks/lamport_clock'
require_relative '../List/LinkedList'

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
    @@pending_queue = LinkedList.new
    @@n_times = n_times
    @@my_id = my_id
  end

  def request_cs(lwa2, lwa3)
    @@lamport_clock.tick
    @@myts = @@lamport_clock.get_value
    lwa2.puts "request-#{@@myts}"
    lwa3.puts "request-#{@@myts}"
    @@num_okay = 0

    loop do
      if @@num_okay < @@n_times - 1
        break
      end
    end

  end

  def release_cs(lwb1, lwb2, lwb3)
    @@myts = Float::INFINITY
    until @@pending_queue.is_empty?
      pid = @@pending_queue.delete(0)

      case pid
        when 0
          lwb1.puts "okay-#{@@myts}"
        when 1
          lwb2.puts "okay-#{@@myts}"
        when 2
          lwb3.puts "okay-#{@@myts}"
        else
          # type code here
      end

    end

  end

  def handle_msg(source, source_id)
    while(msg = source.gets)
      split = msg.split('-')
      time_stamp = split[1].chop.to_i
      @@direct_clock.receive_action(source_id, time_stamp)

      if msg.chop.include? 'request'
        if @@myts == Float::INFINITY || (time_stamp < @@myts) || ((@@myts == time_stamp) && (source < @@my_id))
          source.puts = "okay-#{@@lamport_clock.get_value}"
        else
          @@pending_queue.append(source_id)
        end
      elsif msg.chop.include? 'okay'
        @@num_okay += 1
        # if @@num_okay == @@n_times - 1
        # end
      end
    end
  end
end