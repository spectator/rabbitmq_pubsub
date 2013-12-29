class Consumer
  attr_reader :connection, :workers, :queue

  def initialize
    @connection = Bunny.new
    @connection.start

    @workers = Array.new(8) { |n| Worker.new(connection, n) }
    @queue   = Queue.new
  end

  def run
    workers.each { |w| w.async.call }
    queue.pop
  ensure
    finalize
  end

  def finalize
    connection.stop
  end
end
