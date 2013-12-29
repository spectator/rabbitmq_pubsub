class Producer
  attr_reader :connection, :exchange

  def initialize
    @connection = Bunny.new
    @connection.start

    channel   = connection.create_channel
    @exchange = channel.direct('test')
  end

  def run
    produce_messages
  ensure
    finalize
  end

  def produce_messages
    1.upto(Float::INFINITY) do |message|
      exchange.publish(serialize(message), routing_key: "worker_#{rand(1..8)}")
      puts "Published #{message}"
    end
  end

  def serialize(message)
    JSON.dump(message)
  end

  def finalize
    connection.stop
  end
end
