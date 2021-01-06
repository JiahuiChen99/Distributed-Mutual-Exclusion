class LamportClock
  @@clock

  def initialize
    @@clock = 1
  end

  def get_value
    @@clock
  end

  def tick
    @@clock += 1
  end

  def send_action
    @@clock += 1
  end

  def receive_action(source, sent_value)
    @@clock = [@@clock, sent_value].max + 1
  end

end