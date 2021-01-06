class DirectClock
  @@clock
  @@my_id

  def initialize(numProc, id)
    @@my_id = id
    @@clock = Array.new(numProc)

    numProc.times do |index|
      @@clock[index] = 0
    end

    @@clock[@@my_id] = 1
  end

  def get_value(index)
    @@clock[index]
  end

  def tick
    @@clock[@@my_id] += 1
  end

  def send_action
    tick
  end

  def receive_action(source, sent_value)
    @@clock[source] = [@@clock[source], sent_value].max
    @@clock[@@my_id] = ([@@clock[@@my_id], sent_value].max) + 1
  end

end